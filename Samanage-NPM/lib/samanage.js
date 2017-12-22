'use strict';

var _slicedToArray2 = require('babel-runtime/helpers/slicedToArray');

var _slicedToArray3 = _interopRequireDefault(_slicedToArray2);

var _promise = require('babel-runtime/core-js/promise');

var _promise2 = _interopRequireDefault(_promise);

var _createClass2 = require('babel-runtime/helpers/createClass');

var _createClass3 = _interopRequireDefault(_createClass2);

var _getPrototypeOf = require('babel-runtime/core-js/object/get-prototype-of');

var _getPrototypeOf2 = _interopRequireDefault(_getPrototypeOf);

var _classCallCheck2 = require('babel-runtime/helpers/classCallCheck');

var _classCallCheck3 = _interopRequireDefault(_classCallCheck2);

var _possibleConstructorReturn2 = require('babel-runtime/helpers/possibleConstructorReturn');

var _possibleConstructorReturn3 = _interopRequireDefault(_possibleConstructorReturn2);

var _inherits2 = require('babel-runtime/helpers/inherits');

var _inherits3 = _interopRequireDefault(_inherits2);

var _bluebird = require('bluebird');

var _bluebird2 = _interopRequireDefault(_bluebird);

var _es6Request = require('es6-request');

var _es6Request2 = _interopRequireDefault(_es6Request);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

var ExtendableError = function (_Error) {
  (0, _inherits3['default'])(ExtendableError, _Error);

  function ExtendableError(message) {
    (0, _classCallCheck3['default'])(this, ExtendableError);

    var _this = (0, _possibleConstructorReturn3['default'])(this, (ExtendableError.__proto__ || (0, _getPrototypeOf2['default'])(ExtendableError)).call(this, message));

    _this.name = _this.constructor.name;
    if (typeof Error.captureStackTrace === 'function') {
      Error.captureStackTrace(_this, _this.constructor);
    } else {
      _this.stack = new Error(message).stack;
    }
    return _this;
  }

  return ExtendableError;
}(Error);

var SamanageError = function (_ExtendableError) {
  (0, _inherits3['default'])(SamanageError, _ExtendableError);

  function SamanageError() {
    (0, _classCallCheck3['default'])(this, SamanageError);
    return (0, _possibleConstructorReturn3['default'])(this, (SamanageError.__proto__ || (0, _getPrototypeOf2['default'])(SamanageError)).apply(this, arguments));
  }

  return SamanageError;
}(ExtendableError);

module.exports = function () {
  function samanage(email, password) {
    var platform = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : '';
    (0, _classCallCheck3['default'])(this, samanage);

    this.email = email;
    this.password = password;
    this.base_url = 'https://api' + String(platform) + '.samanage.com/';
    this.authorize();
  }

  (0, _createClass3['default'])(samanage, [{
    key: 'authorize',
    value: function () {
      function authorize() {
        var _this3 = this;

        return new _promise2['default'](function (resolve, reject) {
          var path = 'api.json';
          var url = _this3.base_url + path;
          console.log('URL: ' + url);
          var response = _es6Request2['default'].get(url).headers({
            "Authorization": 'Basic ' + String(Buffer(_this3.email + ':' + _this3.password).toString('base64')),
            "Content-Type": "application/json",
            "Accept": "application/vnd.samanage.v2.0+json"
          }).then(function (_ref) {
            var _ref2 = (0, _slicedToArray3['default'])(_ref, 2),
                body = _ref2[0],
                res = _ref2[1];

            if (res.statusCode < 201) {
              console.log('***Authorizaiton: Success [' + String(_this3.email) + ']');
              resolve([true, res, body]);
            } else {
              var error = new SamanageError('Authorization: Failed [' + String(_this3.email) + ']');
              console.log('Error was: ' + String(error));
              reject([false, res, body]);
              throw error;
            }
          });
        });
      }

      return authorize;
    }()
  }, {
    key: 'find_user',
    value: function () {
      function find_user(email) {
        return new _promise2['default'](function (resolve, reject) {});
      }

      return find_user;
    }()
  }]);
  return samanage;
}();