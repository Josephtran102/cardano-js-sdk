/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable max-len */
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../../../src/NetworkInfo';
import { EraSummary } from '@cardano-sdk/core';
import { HttpServer, HttpServerConfig, createDnsResolver, getPool } from '../../../src';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../../src/InMemoryCache';
import { Pool } from 'pg';
import { SrvRecord } from 'dns';
import { createLogger } from 'bunyan';
import { getPort, getRandomPort } from 'get-port-please';
import { types } from 'util';
import axios from 'axios';

jest.mock('dns', () => ({
  promises: {
    resolveSrv: async (serviceName: string): Promise<SrvRecord[]> => {
      if (serviceName === process.env.POSTGRES_SRV_SERVICE_NAME)
        return [{ name: 'localhost', port: 5433, priority: 6, weight: 5 }];
      return [];
    }
  }
}));

describe('Service dependency abstractions', () => {
  const APPLICATION_JSON = 'application/json';
  const cache = new InMemoryCache(UNLIMITED_CACHE_TTL);
  const cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
  const logger = createLogger({ level: 'error', name: 'test' });
  const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);
  const mockEraSummaries: EraSummary[] = [
    { parameters: { epochLength: 21_600, slotLength: 20_000 }, start: { slot: 0, time: new Date(1_563_999_616_000) } },
    {
      parameters: { epochLength: 432_000, slotLength: 1000 },
      start: { slot: 1_598_400, time: new Date(1_595_964_016_000) }
    }
  ];
  const cardanoNode = {
    eraSummaries: jest.fn(() => Promise.resolve(mockEraSummaries)),
    initialize: jest.fn(() => Promise.resolve()),
    shutdown: jest.fn(() => Promise.resolve()),
    systemStart: jest.fn(() => Promise.resolve(new Date(1_563_999_616_000)))
  };

  describe('Postgres-dependant service with service discovery', () => {
    let httpServer: HttpServer;
    let db: Pool | undefined;
    let port: number;
    let apiUrlBase: string;
    let config: HttpServerConfig;
    let service: NetworkInfoHttpService;
    let networkInfoProvider: DbSyncNetworkInfoProvider;

    beforeAll(async () => {
      db = await getPool(dnsResolver, logger, {
        dbCacheTtl: 10_000,
        epochPollInterval: 1000,
        postgresDb: process.env.POSTGRES_DB!,
        postgresPassword: process.env.POSTGRES_PASSWORD!,
        postgresSrvServiceName: process.env.POSTGRES_SRV_SERVICE_NAME!,
        postgresUser: process.env.POSTGRES_USER!,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });
    });

    describe('Established connection', () => {
      beforeAll(async () => {
        port = await getPort();
        config = { listen: { port } };
        apiUrlBase = `http://localhost:${port}/network-info`;
        networkInfoProvider = new DbSyncNetworkInfoProvider(
          { cardanoNodeConfigPath, epochPollInterval: 2000 },
          { cache, cardanoNode, db: db! }
        );
        service = new NetworkInfoHttpService({ networkInfoProvider });
        httpServer = new HttpServer(config, { services: [service] });

        await httpServer.initialize();
        await httpServer.start();
      });

      afterAll(async () => {
        await db!.end();
        await httpServer.shutdown();
        await cache.shutdown();
        jest.clearAllTimers();
      });

      it('db should be a instance of Proxy ', () => {
        expect(types.isProxy(db!)).toEqual(true);
      });

      it('forwards the db health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });
  });

  describe('Postgres-dependant service with static config', () => {
    let httpServer: HttpServer;
    let db: Pool | undefined;
    let port: number;
    let apiUrlBase: string;
    let config: HttpServerConfig;
    let service: NetworkInfoHttpService;
    let networkInfoProvider: DbSyncNetworkInfoProvider;

    beforeAll(async () => {
      db = await getPool(dnsResolver, logger, {
        dbCacheTtl: 10_000,
        epochPollInterval: 1000,
        postgresConnectionString: process.env.POSTGRES_CONNECTION_STRING
      });
    });

    describe('Established connection', () => {
      beforeAll(async () => {
        port = await getPort();
        config = { listen: { port } };
        apiUrlBase = `http://localhost:${port}/network-info`;
        networkInfoProvider = new DbSyncNetworkInfoProvider(
          { cardanoNodeConfigPath, epochPollInterval: 2000 },
          { cache, cardanoNode, db: db! }
        );
        service = new NetworkInfoHttpService({ networkInfoProvider });
        httpServer = new HttpServer(config, { services: [service] });

        await httpServer.initialize();
        await httpServer.start();
      });

      afterAll(async () => {
        await db!.end();
        await httpServer.shutdown();
        await cache.shutdown();
        jest.clearAllTimers();
      });

      it('db should not be instance a of Proxy ', () => {
        expect(types.isProxy(db!)).toEqual(false);
      });

      it('forwards the db health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });
  });

  describe('Db pool provider with service discovery and Postgres server failover', () => {
    let provider: Pool | undefined;
    const pgPortDefault = 5433;

    it('should resolve successfully if a connection error is thrown and re-connects to a new resolved record', async () => {
      const HEALTH_CHECK_QUERY = 'SELECT 1';
      const srvRecord = { name: 'localhost', port: pgPortDefault, priority: 1, weight: 1 };
      const failingPostgresMockPort = await getRandomPort();
      let resolverAlreadyCalled = false;

      // Initially resolves with a failing postgres port, then swap to the default one
      const dnsResolverMock = jest.fn().mockImplementation(async () => {
        if (!resolverAlreadyCalled) {
          resolverAlreadyCalled = true;
          return { ...srvRecord, port: failingPostgresMockPort };
        }
        return srvRecord;
      });

      provider = await getPool(dnsResolverMock, logger, {
        dbCacheTtl: 10_000,
        epochPollInterval: 1000,
        postgresDb: process.env.POSTGRES_DB!,
        postgresPassword: process.env.POSTGRES_PASSWORD!,
        postgresSrvServiceName: process.env.POSTGRES_SRV_SERVICE_NAME!,
        postgresUser: process.env.POSTGRES_USER!,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });

      const result = await provider!.query(HEALTH_CHECK_QUERY);
      await expect(result.rowCount).toBeTruthy();
      expect(dnsResolverMock).toBeCalledTimes(2);
    });

    it('should execute a provider operation without to intercept it', async () => {
      provider = await getPool(dnsResolver, logger, {
        dbCacheTtl: 10_000,
        epochPollInterval: 1000,
        postgresDb: process.env.POSTGRES_DB!,
        postgresPassword: process.env.POSTGRES_PASSWORD!,
        postgresSrvServiceName: process.env.POSTGRES_SRV_SERVICE_NAME!,
        postgresUser: process.env.POSTGRES_USER!,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });

      await expect(provider!.end()).resolves.toBeUndefined();
    });
  });
});