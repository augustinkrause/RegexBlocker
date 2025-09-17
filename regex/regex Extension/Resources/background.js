// background.js
console.log("Background worker started");

 browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
     console.log(message);
     if (message.action == "getPatterns") {
         browser.runtime.sendNativeMessage({
             action: "getPatterns"
         }).then((response) => {
             console.log(response);
             if (response.success && response.eventName == "getResponse"){
                 sendResponse(response);
             }else{
                 console.log("Getting patterns failed.");
                 sendResponse(null);
             }
         }).catch((error) => {console.error(error)});
     }else if (message.action == "savePatterns") {
             browser.runtime.sendNativeMessage({
                 action: "savePatterns",
                 patterns: message.patterns
             }).then((response) => {
                 console.log(response);
                 if (response.success && response.eventName == "saveResponse"){
                     sendResponse(response);
                 }else{
                     console.log("Saving patterns failed.");
                     sendResponse(null);
                 }
             }).catch((error) => {console.error(error)});
     }else if (message.action == "getPasswordSaved"){
         browser.runtime.sendNativeMessage({
             action: "getPasswordSaved"
         }).then((response) => {
             console.log(response);
             if (response.success && response.eventName == "passwordResponse"){
                 sendResponse(response);
             }else{
                 console.log("Getting password status failed.");
                 sendResponse(null);
             }
         }).catch((error) => {console.error(error)});
     }
     return true;
});

