# 'dataset' holds the input data for this script
library("RCurl")
library("rjson")
library("stats")

######################################

colnames(dataset)<-NULL
values<-list(dataset)
for (i in seq(nrow(dataset))){
  values[[i]] <- as.list(dataset[i,]<-rapply(dataset[i,], as.character))
}

# Accept SSL certificates issued by public Certificate Authorities
options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))

h = basicTextGatherer()
hdr = basicHeaderGatherer()

###################################### Copy from Azure Machine Learning Studion R sample

req = list(
        Inputs = list(            
                "input1" = list(
                              "ColumnNames" = list("Day", "Temperature", "Rainfall", "Flyers", "Price"),
                              "Values" = values
                )                
        ),
        GlobalParameters = setNames(fromJSON('{}'), character(0))
)

body = enc2utf8(toJSON(req))
api_key = "jQQ==" # Replace this with the API key for the web service
authz_hdr = paste('Bearer', api_key, sep=' ')

h$reset()
curlPerform(url = "https://ussouthcentral.services.azureml.net/workspaces/e261c2/services/b05f5/execute?api-version=2.0&details=true",
            httpheader=c('Content-Type' = "application/json", 'Authorization' = authz_hdr),
            postfields=body,
            writefunction = h$update,
            headerfunction = hdr$update,
            verbose = TRUE
            )

headers = hdr$value()
httpStatus = headers["status"]
if (httpStatus >= 400)
{
    print(paste("The request failed with status code:", httpStatus, sep=" "))

    # Print the headers - they include the requert ID and the timestamp, which are useful for debugging the failure
    print(headers)
}

#######################################

print("Result:")
result = h$value()
jsonresult = fromJSON(result)
for (i in 1:length(jsonresult$Results$output1$value$Values)){
  print(jsonresult$Results$output1$value$Values[[i]][6])
} 

output1<-do.call(rbind, jsonresult$Results$output1$value$Values)
colnames(output1)<-c("Day", "Temperature", "Rainfall", "Flyers", "Price", "PredictedSales")

output<-data.frame(output1)

#####################################