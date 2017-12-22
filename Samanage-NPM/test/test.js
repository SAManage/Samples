const Promise = require('bluebird')
const chai = require('chai')
const chaiAsPromised = require('chai-as-promised')
const expect = chai.expect
const assert = chai.assert
const samanage = require('../lib/samanage.js')
const email = 'chris.walls+apitest@samanage.com'
const pass = 'Test1234'
const invalidEmail = email + email
const invalidPass = pass + pass


chai.use(chaiAsPromised)

describe('Samanage', () => {
  it('should check auth', () => {
    let controller = new samanage(email,pass)
    return Promise.resolve(controller.authorize()).then((conn) => {
      console.log(`conn: ${conn}`);
      expect(conn[0]).to.equal(true)
    })
  })
  it('should fail for bad email', () => {
    let fakeEmail = 'nil'
    let fakePass = 'false'
    let controller = new samanage(fakeEmail,fakePass)
    return Promise.resolve(controller.authorize()).then((conn) => {
      console.log(`Conn: ${conn}`)
      expect(conn).to.throw()
    }).catch((error) => {
      console.log(`Err: ${error}`)
      assert.isNotOk(error, "Authentication Error")
    })
  })
});
// console.log(`Controller: ${controller}`)
// console.log(`Authorization: ${controller.authorize()}`)
// console.log(`samanage.default: ${samanage.default(email,pass)}`)