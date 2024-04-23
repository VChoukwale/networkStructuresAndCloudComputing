import sequelize from "../config/dbConfig.js";
import logger from "../config/logger.js";

const checkHealth = (req, res) => {
    try {
      logger.debug("Performing health check");

      if (req.method != 'GET') {
        res.set('Pragma', 'no-cache');
        res.set('X-Content-Type-Options', 'nosniff')
        res.set('Cache-Control', 'no-cache, no-store, must-revalidate');
        res.status(405).send();
        return;
      }
  
      // Request body should not have any payload
      if (Object.keys(req.body).length > 0 || JSON.stringify(req._body) && typeof(req._body) !== '{}') {
  
        // If payload is present, HTTP response should be 'Status: 400 Bad Request'
        console.log("Payload present, returning 400 Bad Request");
        res.set('Pragma', 'no-cache');
        res.set('X-Content-Type-Options', 'nosniff')
        res.set('Cache-Control', 'no-cache, no-store, must-revalidate');
        res.status(400).send();
        logger.error("Payload present, returning 400 Bad Request", {error: error.message});
        return;
      }
  
      // API request should not have query parameters
      if (Object.keys(req.query).length !== 0) {
  
        // If query parameters are present, HTTP response should be 'Status: 400 Bad Request'
        
        res.set('Pragma', 'no-cache');
        res.set('X-Content-Type-Options', 'nosniff')
        res.set('Cache-Control', 'no-cache, no-store, must-revalidate');
        res.status(400).send();
        logger.error("Query parameters present, returning 400 Bad Request", {error: error.message});
        return;
      }
  
      // If MySQL connection is successful, HTTP response should be 'Status: 200 OK'
      logger.warn('No payload, checking MySQL connection');
      sequelize.authenticate()
        .then(() => {

          logger.info("MySQL connection successful, returning 200 OK");

          res.set('Pragma', 'no-cache');
          res.set('X-Content-Type-Options', 'nosniff')
          res.set('Cache-Control', 'no-cache, no-store, must-revalidate');
          res.status(200).send();
        })
  
        .catch((error) => {
          logger.error('MySQL connection unsuccessful, returning 503 Service Unavailable:', { error: error.message });
          res.set('Pragma', 'no-cache');
          res.set('X-Content-Type-Options', 'nosniff')
          res.set('Cache-Control', 'no-cache, no-store, must-revalidate');
          res.status(503).send();
        });
    } catch (error) {
  
      // If there is an exception, HTTP response should be 'Status: 503 Service Unavailable'
      logger.error('Exception occurred, returning 503 Service Unavailable:', { error: error.message });
      res.set('Pragma', 'no-cache');
      res.set('X-Content-Type-Options', 'nosniff')
      res.set('Cache-Control', 'no-cache, no-store, must-revalidate');
      res.status(503).send();
    }
  };
  
  export default {
    checkHealth,
  };
  