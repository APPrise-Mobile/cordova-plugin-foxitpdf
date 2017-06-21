var exec = require('cordova/exec');

var pdf = function(){};

pdf.prototype.init = function(serial, key, success, error) {
    exec(success, error, "FoxitPdf", "init", [serial, key]);
};

pdf.prototype.openPDFAtPath =  function(filePath, isReadOnly, success, error) {
    exec(success, error, "FoxitPdf", "Preview", [filePath, isReadOnly]);
};

var pdf = new pdf();
module.exports = pdf;
