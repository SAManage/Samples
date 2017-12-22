"use strict";

const url = require("url");
const http = require("http");
const https = require("https");
const qs = require("querystring");
const Duplex = require("stream").Duplex;
const methods = ["PUT", "POST", "PATCH", "DELETE", "GET", "HEAD", "OPTIONS"];
const writeMethods = ["PUT", "POST", "PATCH"];

var InvalidProtocolError = new Error("Invalid protocol");
InvalidProtocolError.code = "invalid_protocol";

var InvalidMethodError = new Error("Invalid method");
InvalidMethodError.code = "invalid_method";

class Request extends Duplex {
  constructor(method, urlStr) {
    // initialize duplex stream
    super()

    // parse url string
    this.url = url.parse(urlStr);

    // create base options object
    this.options = {
      hostname: this.url.hostname,
      path: this.url.pathname,
      method: method,
      headers: {}
    };

    this.qs = qs.parse(this.url.query) || {};

    // validate method
    if (methods.indexOf(this.options.method) == -1) {
      throw InvalidMethodError;
    }

    this.on("pipe", src => {
      if (this._active) {
        this.emit("error", new Error("You cannot pipe to this stream after starting the http request."));
      }
    });

    return this;
  }

  headers(obj) {
    Object.assign(this.options.headers, obj);
    return this;
  }

  header(key, val) {
    this.options.headers[key] = val;
    return this;
  }

  options(obj) {
    Object.assign(this.options, obj);
    return this;
  }

  option(key, val) {
    this.options[key] = val;
    return this;
  }

  query(key, val) {
    if (typeof key == "object") {
      Object.assign(this.qs, key);
    } else {
      this.qs[key] = val;
    }

    return this;
  }

  start() {
    if (Object.keys(this.qs).length > 0) this.options.path = this.url.pathname + "?" + qs.stringify(this.qs);

    // protocol switch
    switch (this.url.protocol) {
      case "https:":
        this.options.port = this.url.port || 443;
        this.req = https.request(this.options);
        this._started = true;
        break;

      case "http:":
        this.options.port = this.url.port || 80;
        this.req = http.request(this.options);
        this._started = true;
        break;

      default:
        throw InvalidProtocolError;
        break;
    }

    return this;
  }

  then(onFailure, onSuccess) {
    return this.perform().then(onFailure, onSuccess);
  }

  catch(onFailure) {
    return this.perform().catch(onFailure);
  }

  perform() {
    return new Promise((resolve, reject) => {
      if (!this._started) {
        this.start();
      }

      this._active = true;

      this.req.on("error", (e) => {
        reject(e);
      });

      this.req.on("response", (res) => {
        this.res = res;
        this.body = [];

        res.on("data", (chunk) => {
          this.push(chunk);
          this.body.push(chunk);
        });

        res.on("end", () => {
          this._active = false;

          this.push(null);
          resolve([Buffer.concat(this.body).toString(), res]);
        });

        res.on("error", (e) => {
          reject(e);
        });
      });

      this.req.end();
    });
  }

  write(chunk, encoding, callback) {
    if (!this._started) {
      this.start();
    }

    this.req.write(chunk, encoding, callback);
    return this;
  }

  pipe(dest, opt) {
    Duplex.prototype.pipe.call(this, dest, opt);
    return this;
  }

  _read(size) {}

  send(body, encoding, callback) {
    return this.write(body, encoding, callback).perform();
  }

  json(object) {
    const data = qs.stringify(object);
    return this.headers({"Content-Type": "x-www-form-urlencoded", "Content-Length": data.length}).send(data);
  }
}

class HTTP {}

methods.forEach((method) => {
  HTTP[method.toLowerCase()] = (urlStr) => {
    return new Request(method, urlStr);
  }
});

module.exports = HTTP;
