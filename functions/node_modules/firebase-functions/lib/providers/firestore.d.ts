import * as firebase from 'firebase-admin';
import { CloudFunction, Change, EventContext } from '../cloud-functions';
export declare type DocumentSnapshot = firebase.firestore.DocumentSnapshot;
export declare function document(path: string): DocumentBuilder;
export declare class DatabaseBuilder {
    private database;
    namespace(namespace: string): NamespaceBuilder;
    document(path: string): DocumentBuilder;
}
export declare class NamespaceBuilder {
    private database;
    private namespace;
    document(path: string): DocumentBuilder;
}
export declare class DocumentBuilder {
    private triggerResource;
    /** Respond to all document writes (creates, updates, or deletes). */
    onWrite(handler: (change: Change<DocumentSnapshot>, context: EventContext) => PromiseLike<any> | any): CloudFunction<Change<DocumentSnapshot>>;
    /** Respond only to document updates. */
    onUpdate(handler: (change: Change<DocumentSnapshot>, context: EventContext) => PromiseLike<any> | any): CloudFunction<Change<DocumentSnapshot>>;
    /** Respond only to document creations. */
    onCreate(handler: (snapshot: DocumentSnapshot, context: EventContext) => PromiseLike<any> | any): CloudFunction<DocumentSnapshot>;
    /** Respond only to document deletions. */
    onDelete(handler: (snapshot: DocumentSnapshot, context: EventContext) => PromiseLike<any> | any): CloudFunction<DocumentSnapshot>;
    private onOperation<T>(handler, eventType, dataConstructor);
}
