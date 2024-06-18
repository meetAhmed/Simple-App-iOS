//
//  PortalsPlugin+Combine.swift
//  IonicPortals
//
//  Created by Steven Sherry on 3/2/22.
//

import Foundation
import Combine
import Capacitor

extension PortalsPubSub {
    public struct Publisher: Combine.Publisher {
        public typealias Output = SubscriptionResult
        public typealias Failure = Never

        private let subject: PassthroughSubject<SubscriptionResult, Never>

        init(topic: String, pubsub: PortalsPubSub) {
            subject = pubsub.subject(for: topic)
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            subject.receive(subscriber: subscriber)
        }
    }
    
    /// Subscribes to a topic and publishes a ``SubscriptionResult`` downstream
    /// - Parameter topic: The topic to subscribe to
    /// - Returns: A ``Publisher``
    public func publisher(for topic: String) -> Publisher {
        Publisher(topic: topic, pubsub: self)
    }
    
    /// Subscribes to a topic and publishes a ``SubscriptionResult`` downstream. Uses ``shared`` to subscribe.
    /// - Parameter topic: The topic to subscribe to
    /// - Returns: A ``Publisher``
    public static func publisher(for topic: String) -> Publisher {
        Publisher(topic: topic, pubsub: shared)
    }
}

extension PortalsPubSub.Publisher {
    /// Error to be thrown when casting from JSValue to concrete value fails
    public struct CastingError<T>: Error, CustomStringConvertible {
        public let description = "Unable to cast JSValue to \(T.self)"
    }
    
    /// Extracts the ``SubscriptionResult/data`` value from ``SubscriptionResult``
    /// - Returns: A publisher emitting the ``SubscriptionResult/data`` value from the upstream ``SubscriptionResult``
    public func data() -> AnyPublisher<JSValue?, Never> {
        map(\.data)
            .eraseToAnyPublisher()
    }
    
    /// Attempts to cast the ``SubscriptionResult/data`` value of the upstream ``SubscriptionResult``
    /// - Parameter type: The concrete `JSValue` to cast ``SubscriptionResult/data`` to
    /// - Returns: A publisher emitting the an optional value after attempting to cast the ``SubscriptionResult/data`` value to a concrete type
    public func data<T>(as type: T.Type = T.self) -> AnyPublisher<T?, Never> where T: JSValue {
        map { $0.data as? T }
            .eraseToAnyPublisher()
    }
    
    /// Attempts to cast the ``SubscriptionResult/data`` value of the upstream ``SubscriptionResult`` and throws an error if unsuccessful
    /// - Parameter type: The concrete `JSValue` to cast ``SubscriptionResult/data`` to
    /// - Returns: A publisher emitting the cast value or a ``CastingError``
    public func tryData<T>(as type: T.Type = T.self) -> AnyPublisher<T, Error> where T: JSValue {
        tryMap { result in
            guard let data = result.data as? T else { throw CastingError<T>() }
            return data
        }
        .eraseToAnyPublisher()
    }
    
    /// Attempts to decode the ``SubscriptionResult/data`` value of the upstream ``SubscriptionResult`` to any type that conforms to `Decodable`.
    /// - Parameters:
    ///   - type: The type to decode the ``SubscriptionResult/data`` value of ``SubscriptionResult`` to.
    ///   - decoder: A `JSValueDecoder` to perform decoding.
    /// - Returns: A publisher emitting the decoded value or a decoding error.
    public func decodeData<T>(_ type: T.Type = T.self, decoder: JSValueDecoder = JSValueDecoder()) -> AnyPublisher<T, Error> where T: Decodable {
        tryCompactMap { try $0.decodeData(with: decoder) }
            .eraseToAnyPublisher()
    }
}
