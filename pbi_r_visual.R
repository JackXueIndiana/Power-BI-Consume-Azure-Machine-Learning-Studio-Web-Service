library("RCurl")
library("rjson")
library("stats")

print(dataset)
colnames(dataset)<-NULL
values<-list(dataset)
for (i in seq(nrow(dataset))){
  values[[i]] <- as.list(dataset[i,]<-rapply(dataset[i,], as.character))
}
print(values)

# Accept SSL certificates issued by public Certificate Authorities
options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))

h = basicTextGatherer()
hdr = basicHeaderGatherer()


req = list(
        Inputs = list(            
                "input1" = list(
                              "ColumnNames" = list("Day", "Flyers", "Price", "Rainfall", "Temperature"),
                              "Values" = values
                )                
        ),
        GlobalParameters = setNames(fromJSON('{}'), character(0))
)

body = enc2utf8(toJSON(req))
api_key = "jwBU4EprACzo+b8SlZM1lGiY+nJ2HJXqHdIcmveiEy7dSIMaST8mHyVSuaHXL6f6h/VEt16yl8Gkn221+RalQQ==" # Replace this with the API key for the web service
authz_hdr = paste('Bearer', api_key, sep=' ')

h$reset()
curlPerform(url = "https://ussouthcentral.services.azureml.net/workspaces/e261c2c53b704717a54bbdfef8377355/services/b05f519671ea40b1acdf15db471d4e8e/execute?api-version=2.0&details=true",
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

print("Result:")
result <- h$value()
jsonresult <- fromJSON(result)

############################

#Convert to a dataframe, transpose, and convert the resulting matrix back to a dataframe
mydf<- as.data.frame(t(as.data.frame(jsonresult)))

#Strip out the rownames if desired
rownames(mydf)<-NULL

#Show result
colnames(mydf)<-NULL
mydf<- mydf[-c(1, 2, 3), ]
colnames(mydf)<-c("Day", "Temperature", "Rainfall", "Flyers", "Price", "PredictSales")
plot(mydf)

