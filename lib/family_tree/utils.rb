def dwelve_into

   level = $logger.level
   $logger.level = Logger::DEBUG
   yield
   $logger.level = level
end