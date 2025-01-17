{
  config,
  values,
  lib,
  ...
}: {
  providers.backend = {
    inherit (values.cardano-services) image;
    args = ["start-provider-server"];
    port = 3000;
    metricsPath = "${values.cardano-services.httpPrefix}/metrics";

    livenessProbe = {
      timeoutSeconds = 5;
      httpGet = {
        path = "${values.cardano-services.httpPrefix}/health";
        port = 3000;
      };
    };

    env = {
      NETWORK = values.network;
      ENABLE_METRICS = "true";
      SERVICE_NAMES = "asset,chain-history,network-info,rewards,stake-pool,tx-submit,utxo";
      OGMIOS_SRV_SERVICE_NAME = values.backend.ogmiosSrvServiceName;
      LOGGER_MIN_SEVERITY = values.cardano-services.loggingLevel;
      TOKEN_METADATA_SERVER_URL = values.cardano-services.tokenMetadataServerUrl;

      BUILD_INFO = lib.mkIf (values.cardano-services.buildInfo != null) values.cardano-services.buildInfo;
      ALLOWED_ORIGINS = lib.mkIf (values.backend.allowedOrigins != null) values.backend.allowedOrigins;

      POSTGRES_POOL_MAX_DB_SYNC = "50";
      POSTGRES_HOST_DB_SYNC = values.postgresName;
      POSTGRES_PORT_DB_SYNC = "5432";
      POSTGRES_DB_DB_SYNC = "cardano";
      POSTGRES_PASSWORD_DB_SYNC = {
        valueFrom.secretKeyRef = {
          name = "cardano-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
          key = "password";
        };
      };
      POSTGRES_USER_DB_SYNC = {
        valueFrom.secretKeyRef = {
          name = "cardano-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
          key = "username";
        };
      };
      POSTGRES_SSL_DB_SYNC = "true";
      POSTGRES_SSL_CA_FILE_DB_SYNC = "/tls/ca.crt";

      POSTGRES_POOL_MAX_HANDLE = "10";
      POSTGRES_HOST_HANDLE = values.postgresName;
      POSTGRES_PORT_HANDLE = "5432";
      POSTGRES_DB_HANDLE = "handle";
      POSTGRES_PASSWORD_HANDLE = {
        valueFrom.secretKeyRef = {
          name = "handle-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
          key = "password";
        };
      };
      POSTGRES_USER_HANDLE = {
        valueFrom.secretKeyRef = {
          name = "handle-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
          key = "username";
        };
      };
      POSTGRES_SSL_HANDLE = "true";
      POSTGRES_SSL_CA_FILE_HANDLE = "/tls/ca.crt";
    };
  };
}
