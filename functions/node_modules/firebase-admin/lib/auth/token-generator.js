/*! firebase-admin v5.12.1 */
"use strict";
/*!
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
Object.defineProperty(exports, "__esModule", { value: true });
var error_1 = require("../utils/error");
var validator = require("../utils/validator");
var tokenVerify = require("./token-verifier");
var jwt = require("jsonwebtoken");
var ALGORITHM_RS256 = 'RS256';
var ONE_HOUR_IN_SECONDS = 60 * 60;
// List of blacklisted claims which cannot be provided when creating a custom token
var BLACKLISTED_CLAIMS = [
    'acr', 'amr', 'at_hash', 'aud', 'auth_time', 'azp', 'cnf', 'c_hash', 'exp', 'iat', 'iss', 'jti',
    'nbf', 'nonce',
];
// URL containing the public keys for the Google certs (whose private keys are used to sign Firebase
// Auth ID tokens)
var CLIENT_CERT_URL = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com';
// URL containing the public keys for Firebase session cookies. This will be updated to a different URL soon.
var SESSION_COOKIE_CERT_URL = 'https://www.googleapis.com/identitytoolkit/v3/relyingparty/publicKeys';
// Audience to use for Firebase Auth Custom tokens
var FIREBASE_AUDIENCE = 'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit';
/** User facing token information related to the Firebase session cookie. */
exports.SESSION_COOKIE_INFO = {
    url: 'https://firebase.google.com/docs/auth/admin/manage-cookies',
    verifyApiName: 'verifySessionCookie()',
    jwtName: 'Firebase session cookie',
    shortName: 'session cookie',
    expiredErrorCode: 'auth/session-cookie-expired',
};
/** User facing token information related to the Firebase ID token. */
exports.ID_TOKEN_INFO = {
    url: 'https://firebase.google.com/docs/auth/admin/verify-id-tokens',
    verifyApiName: 'verifyIdToken()',
    jwtName: 'Firebase ID token',
    shortName: 'ID token',
    expiredErrorCode: 'auth/id-token-expired',
};
/**
 * Class for generating and verifying different types of Firebase Auth tokens (JWTs).
 */
var FirebaseTokenGenerator = /** @class */ (function () {
    function FirebaseTokenGenerator(certificate) {
        if (!certificate) {
            throw new error_1.FirebaseAuthError(error_1.AuthClientErrorCode.INVALID_CREDENTIAL, 'INTERNAL ASSERT: Must provide a certificate to use FirebaseTokenGenerator.');
        }
        this.certificate_ = certificate;
        this.sessionCookieVerifier = new tokenVerify.FirebaseTokenVerifier(SESSION_COOKIE_CERT_URL, ALGORITHM_RS256, 'https://session.firebase.google.com/', this.certificate_.projectId, exports.SESSION_COOKIE_INFO);
        this.idTokenVerifier = new tokenVerify.FirebaseTokenVerifier(CLIENT_CERT_URL, ALGORITHM_RS256, 'https://securetoken.google.com/', this.certificate_.projectId, exports.ID_TOKEN_INFO);
    }
    /**
     * Creates a new Firebase Auth Custom token.
     *
     * @param {string} uid The user ID to use for the generated Firebase Auth Custom token.
     * @param {object} [developerClaims] Optional developer claims to include in the generated Firebase
     *                 Auth Custom token.
     * @return {Promise<string>} A Promise fulfilled with a Firebase Auth Custom token signed with a
     *                           service account key and containing the provided payload.
     */
    FirebaseTokenGenerator.prototype.createCustomToken = function (uid, developerClaims) {
        var errorMessage;
        if (typeof uid !== 'string' || uid === '') {
            errorMessage = 'First argument to createCustomToken() must be a non-empty string uid.';
        }
        else if (uid.length > 128) {
            errorMessage = 'First argument to createCustomToken() must a uid with less than or equal to 128 characters.';
        }
        else if (!this.isDeveloperClaimsValid_(developerClaims)) {
            errorMessage = 'Second argument to createCustomToken() must be an object containing the developer claims.';
        }
        if (typeof errorMessage !== 'undefined') {
            throw new error_1.FirebaseAuthError(error_1.AuthClientErrorCode.INVALID_ARGUMENT, errorMessage);
        }
        if (!validator.isNonEmptyString(this.certificate_.privateKey)) {
            errorMessage = 'createCustomToken() requires a certificate with "private_key" set.';
        }
        else if (!validator.isNonEmptyString(this.certificate_.clientEmail)) {
            errorMessage = 'createCustomToken() requires a certificate with "client_email" set.';
        }
        if (typeof errorMessage !== 'undefined') {
            throw new error_1.FirebaseAuthError(error_1.AuthClientErrorCode.INVALID_CREDENTIAL, errorMessage);
        }
        var jwtPayload = {};
        if (typeof developerClaims !== 'undefined') {
            var claims = {};
            for (var key in developerClaims) {
                /* istanbul ignore else */
                if (developerClaims.hasOwnProperty(key)) {
                    if (BLACKLISTED_CLAIMS.indexOf(key) !== -1) {
                        throw new error_1.FirebaseAuthError(error_1.AuthClientErrorCode.INVALID_ARGUMENT, "Developer claim \"" + key + "\" is reserved and cannot be specified.");
                    }
                    claims[key] = developerClaims[key];
                }
            }
            jwtPayload.claims = claims;
        }
        jwtPayload.uid = uid;
        var customToken = jwt.sign(jwtPayload, this.certificate_.privateKey, {
            audience: FIREBASE_AUDIENCE,
            expiresIn: ONE_HOUR_IN_SECONDS,
            issuer: this.certificate_.clientEmail,
            subject: this.certificate_.clientEmail,
            algorithm: ALGORITHM_RS256,
        });
        return Promise.resolve(customToken);
    };
    /**
     * Verifies the format and signature of a Firebase Auth ID token.
     *
     * @param {string} idToken The Firebase Auth ID token to verify.
     * @return {Promise<object>} A promise fulfilled with the decoded claims of the Firebase Auth ID
     *                           token.
     */
    FirebaseTokenGenerator.prototype.verifyIdToken = function (idToken) {
        return this.idTokenVerifier.verifyJWT(idToken);
    };
    /**
     * Verifies the format and signature of a Firebase session cookie JWT.
     *
     * @param {string} sessionCookie The Firebase session cookie to verify.
     * @return {Promise<object>} A promise fulfilled with the decoded claims of the Firebase session
     *                           cookie.
     */
    FirebaseTokenGenerator.prototype.verifySessionCookie = function (sessionCookie) {
        return this.sessionCookieVerifier.verifyJWT(sessionCookie);
    };
    /**
     * Returns whether or not the provided developer claims are valid.
     *
     * @param {object} [developerClaims] Optional developer claims to validate.
     * @return {boolean} True if the provided claims are valid; otherwise, false.
     */
    FirebaseTokenGenerator.prototype.isDeveloperClaimsValid_ = function (developerClaims) {
        if (typeof developerClaims === 'undefined') {
            return true;
        }
        return validator.isNonNullObject(developerClaims);
    };
    return FirebaseTokenGenerator;
}());
exports.FirebaseTokenGenerator = FirebaseTokenGenerator;
