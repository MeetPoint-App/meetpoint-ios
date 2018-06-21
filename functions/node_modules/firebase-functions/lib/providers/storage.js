"use strict";
// The MIT License (MIT)
//
// Copyright (c) 2017 Firebase
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
Object.defineProperty(exports, "__esModule", { value: true });
const cloud_functions_1 = require("../cloud-functions");
const config_1 = require("../config");
/** @internal */
exports.provider = 'google.storage';
/** @internal */
exports.service = 'storage.googleapis.com';
/**
 * The optional bucket function allows you to choose which buckets' events to handle.
 * This step can be bypassed by calling object() directly, which will use the bucket that
 * the Firebase SDK for Cloud Storage uses.
 */
function bucket(bucket) {
    const resourceGetter = () => {
        bucket = bucket || config_1.firebaseConfig().storageBucket;
        if (!bucket) {
            throw new Error('Missing bucket name. If you are unit testing, please provide a bucket name' +
                ' through `functions.storage.bucket(bucketName)`, or set process.env.FIREBASE_CONFIG.');
        }
        if (!/^[a-z\d][a-z\d\\._-]{1,230}[a-z\d]$/.test(bucket)) {
            throw new Error('Invalid bucket name ${bucket}');
        }
        return `projects/_/buckets/${bucket}`;
    };
    return new BucketBuilder(resourceGetter);
}
exports.bucket = bucket;
function object() {
    return bucket().object();
}
exports.object = object;
class BucketBuilder {
    /** @internal */
    constructor(triggerResource) {
        this.triggerResource = triggerResource;
    }
    /** Handle events for objects in this bucket. */
    object() {
        return new ObjectBuilder(this.triggerResource);
    }
}
exports.BucketBuilder = BucketBuilder;
class ObjectBuilder {
    /** @internal */
    constructor(triggerResource) {
        this.triggerResource = triggerResource;
    }
    /** @internal */
    onChange(handler) {
        throw new Error('"onChange" is now deprecated, please use "onArchive", "onDelete", ' +
            '"onFinalize", or "onMetadataUpdate".');
    }
    /** Respond to archiving of an object, this is only for buckets that enabled object versioning. */
    onArchive(handler) {
        return this.onOperation(handler, 'object.archive');
    }
    /** Respond to the deletion of an object (not to archiving, if object versioning is enabled). */
    onDelete(handler) {
        return this.onOperation(handler, 'object.delete');
    }
    /** Respond to the successful creation of an object. */
    onFinalize(handler) {
        return this.onOperation(handler, 'object.finalize');
    }
    /** Respond to metadata updates of existing objects. */
    onMetadataUpdate(handler) {
        return this.onOperation(handler, 'object.metadataUpdate');
    }
    onOperation(handler, eventType) {
        return cloud_functions_1.makeCloudFunction({
            handler,
            provider: exports.provider,
            service: exports.service,
            eventType,
            triggerResource: this.triggerResource,
        });
    }
}
exports.ObjectBuilder = ObjectBuilder;
