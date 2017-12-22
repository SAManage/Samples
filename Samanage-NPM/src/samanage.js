import promise from 'bluebird'
import request from "es6-request"


class ExtendableError extends Error {
  constructor(message) {
    super(message);
    this.name = this.constructor.name;
    if (typeof Error.captureStackTrace === 'function') {
      Error.captureStackTrace(this, this.constructor);
    } else {
      this.stack = (new Error(message)).stack;
    }
  }
}

class SamanageError extends ExtendableError {}

module.exports = class samanage {
  constructor(email, password, platform = '') {
    this.email = email
    this.password = password
    this.base_url = `https://api${platform}.samanage.com/`
    this.authorize()
  }
  authorize() {
    return new Promise((resolve, reject) => {
      let path = 'api.json'
      let url = this.base_url + path
      console.log(`URL: ${url}`)
      const response = request.get(url)
      .headers({
        "Authorization": `Basic ${Buffer(this.email + ':' + this.password).toString('base64')}`,
        "Content-Type": "application/json",
        "Accept": "application/vnd.samanage.v2.0+json"
      })
      .then(([body, res]) => {
        if(res.statusCode < 201) {
          console.log(`***Authorizaiton: Success [${this.email}]`)
          resolve([true,res,body])
        }
        else {
          let error =  new SamanageError(`Authorization: Failed [${this.email}]`)
          console.log(`Error was: ${error}`)
          reject([false,res,body])
          throw error
        }
      })
    })
  }
  find_user(email) {
    return new Promise((resolve, reject) => {

    })
  }
}