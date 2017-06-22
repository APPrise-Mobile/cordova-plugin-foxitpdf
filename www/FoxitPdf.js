var exec = require('cordova/exec');

var pdf = function(){};

pdf.prototype.init = function(serial, key, success, error) {
    exec(success, error, "FoxitPdf", "init", [serial, key]);
};

pdf.prototype.openPDFAtPath =  function(filePath, options, success, error) {
    exec(success, error, "FoxitPdf", "openPdf", [filePath, options]);
};

var pdf = new pdf();
module.exports = pdf;
