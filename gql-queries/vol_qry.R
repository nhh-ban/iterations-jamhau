# Load the required libraries and functions
library(httr)
library(jsonlite)


GQL <- read_file("gql-queries/station_metadata.gql")


url <- "https://www.vegvesen.no/trafikkdata/api/"

query <- '
{
  trafficData(trafficRegistrationPointId: "97411V72313") {
    volume {
      byHour(from: "2022-05-01T06:55:47Z", to: "2022-05-08T06:55:47Z") {
        edges {
          node {
            from
            to
            total {
              volumeNumbers {
                volume
              }
            }
          }
        }
      }
    }
  }
}
'



to_iso8601 <- function(date_time) {
  # Convert a Date-Time object to ISO 8601 format
  iso8601_date_time <- format(date_time, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  return(iso8601_date_time)
}
# data_transformations.r

to_iso8601 <- function(date_time, offset_days) {
  # Add the offset in days to the date-time
  adjusted_date_time <- date_time + days(offset_days)
  
  # Convert the adjusted date-time object to ISO 8601 format
  iso8601_date_time <- format(adjusted_date_time, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  
  return(iso8601_date_time)
}
to_iso8601(as_datetime("2016-09-01 10:11:12"),0)


to_iso8601(as_datetime("2016-09-01 10:11:12"),-4)


# Define the vol_qry function
vol_qry <- function(id, from, to) {
  # Create the GraphQL query using the provided arguments
  query <- paste('{
    trafficData(trafficRegistrationPointId: "', id, '") {
      volume {
        byHour(from: "', from, '", to: "', to, '") {
          edges {
            node {
              from
              to
              total {
                volumeNumbers {
                  volume
                }
              }
            }
          }
        }
      }
    }
  }', sep = '')
  
  return(query)
}

GQL(
  vol_qry(
    id=stations_metadata_df$id[1], 
    from=to_iso8601(stations_metadata_df$latestData[1],-4),
    to=to_iso8601(stations_metadata_df$latestData[1],0)
  ),
  .url = configs$vegvesen_url
)

