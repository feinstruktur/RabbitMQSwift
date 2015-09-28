//
//  AMQPExchange.swift
//  RabbitMQSwift
//
//  Created by Carl Gleisner on 2014-08-09.
//  Copyright (c) 2014 Carl Gleisner. All rights reserved.
//

import Foundation

class AMQPExchange : AMQPObject {
    
    private var exchange : amqp_bytes_t
    private var channel : AMQPChannel
    private var initialized = false
    
    override init() {
        exchange = amqp_empty_bytes
        channel = AMQPChannel()
    }
    
    private init(type : NSString, name : NSString, channel : AMQPChannel) {
        exchange = amqp_empty_bytes
        self.channel = channel
        
//        amqp_exchange_declare(channel.connection.internalConnection(), channel.internalChannel(), amqp_cstring_bytes(name.UTF8String), amqp_cstring_bytes(type.UTF8String), 0, 0, amqp_empty_table)

        
        amqp_exchange_declare(channel.connection.internalConnection(), channel.internalChannel(), amqp_cstring_bytes(name.UTF8String), amqp_cstring_bytes(type.UTF8String), 0, 0, 0, 0, amqp_empty_table)
        
        if (channel.connection.checkLastOperation("Declaring exchange")) {
            exchange = amqp_bytes_malloc_dup(amqp_cstring_bytes(name.UTF8String))
            initialized = true
        } else {
            
        }
    }
    
    convenience init(directExchange name : String, channel : AMQPChannel) {
        self.init(type: "direct", name: name, channel: channel)
    }
    
    convenience init(fanoutExchange name : String, channel : AMQPChannel) {
        self.init(type: "fanout", name: name, channel: channel)
    }
    
    convenience init(topicExchange name : String, channel : AMQPChannel) {
        self.init(type: "topic", name: name, channel: channel)
    }
    
    convenience init(headersExchange name : String, channel : AMQPChannel) {
        self.init(type: "headers", name: name, channel: channel)
    }
    
    deinit {
        amqp_bytes_free(exchange)
    }
    
    func isInitialized() -> Bool {
        return initialized
    }
    
    func internalExchange() -> amqp_bytes_t {
        if (initialized == false) {
            print("Warning! Tried to access internal exchange while not initialized")
        }
        
        return exchange
    }
    
    func publishMessage(body : NSString, routingKey : NSString) {
        if (initialized) {
            amqp_basic_publish(channel.connection.internalConnection(), channel.internalChannel(), self.internalExchange(), amqp_cstring_bytes(routingKey.UTF8String), 0, 0, nil, amqp_cstring_bytes(body.UTF8String))
        
            channel.connection.checkLastOperation("Publishing message")
        } else {
            print("Cannot publish before exchange has been initialized.")
        }
    }
    
}