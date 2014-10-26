//
//  AMQPQueue.swift
//  RabbitMQSwift
//
//  Created by Carl Gleisner on 2014-08-09.
//  Copyright (c) 2014 Carl Gleisner. All rights reserved.
//

import Foundation
import Cocoa

class AMQPQueue : AMQPObject {

    var channel : AMQPChannel
    private var queueName : amqp_bytes_t
    
    override init() {
        channel = AMQPChannel()
        queueName = amqp_empty_bytes
    }
    
    init(channel: AMQPChannel) {
        self.channel = channel
        var result = UnsafeMutablePointer<amqp_queue_declare_ok_t>()
        result = amqp_queue_declare(channel.connection.internalConnection(), 1, amqp_empty_bytes, 0, 0, 0, 1,
            amqp_empty_table)
        
        if (self.channel.connection.checkLastOperation("Declare queue")) {
            queueName = amqp_bytes_malloc_dup(result.memory.queue)
        } else {
            queueName = amqp_empty_bytes
            return
        }
    }
    
    init(name: NSString, channel: AMQPChannel) {
        self.channel = channel
        var result = UnsafeMutablePointer<amqp_queue_declare_ok_t>()
        result = amqp_queue_declare(channel.connection.internalConnection(), 1, amqp_cstring_bytes(name.UTF8String), 0, 0, 0, 1,
            amqp_empty_table)
        
        self.channel.connection.checkLastOperation("Declare queue1")
        
        queueName = amqp_bytes_malloc_dup(result.memory.queue)
    }
    
    deinit {
        amqp_bytes_free(queueName)
    }
    
    func bindToExchange(exchange: AMQPExchange, bindingKey: NSString) {
        amqp_queue_bind(channel.connection.internalConnection(), channel.internalChannel(), queueName, exchange.internalExchange(), amqp_cstring_bytes(bindingKey.UTF8String), amqp_empty_table)
        
        channel.connection.checkLastOperation("Bind queue to exchange")
    }
    
    func unbindFromExchange(exchange: AMQPExchange, routingKey: NSString) {
        amqp_queue_unbind(channel.connection.internalConnection(), channel.internalChannel(), queueName, exchange.internalExchange(), amqp_cstring_bytes(routingKey.UTF8String) , amqp_empty_table)
        channel.connection.checkLastOperation("Unbind from exchange")
    }
    
    func internalQueue() -> amqp_bytes_t {
        return queueName
    }
    
}
