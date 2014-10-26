//
//  AMQPConsumer.swift
//  RabbitMQSwift
//
//  Created by Carl Gleisner on 2014-08-10.
//  Copyright (c) 2014 Carl Gleisner. All rights reserved.
//

import Foundation

class AMQPConsumer : AMQPObject {
    var channel : AMQPChannel
    var queue : AMQPQueue
    private var consumer = amqp_empty_bytes
    
    override init() {
        channel = AMQPChannel()
        queue = AMQPQueue()
    }
    
    init(queue: AMQPQueue, channel: AMQPChannel, useAcks : Bool, isExclusive : Bool, receiveLocalmessages : Bool) {
        
        // TODO: Move!
        func amqpBoolean(value : Bool) -> amqp_boolean_t {
            if (value) {
                return Int32(1)
            } else {
                return(0)
            }
        }
        
        self.channel = channel
        self.queue = queue        
        
        let result = amqp_basic_consume(channel.connection.internalConnection(), channel.internalChannel(), queue.internalQueue(), amqp_empty_bytes, amqpBoolean(!receiveLocalmessages), amqpBoolean(!useAcks), amqpBoolean(isExclusive), amqp_empty_table)
        
        channel.connection.checkLastOperation("Start consumer")
        
        consumer = amqp_bytes_malloc_dup(result.memory.consumer_tag)
        
    }
    
    deinit {
        amqp_bytes_free(consumer)
    }
    
    func pop() -> AMQPMessage {
        println("Entered pop()")
        
        var message = AMQPMessage()
        var messageDone = false
        var result : Int32 = Int32(-1)
        var frame = UnsafeMutablePointer<amqp_frame_t>.alloc(sizeof(amqp_frame_t))
        var receivedBytes : size_t = 0
        var body : amqp_bytes_t = amqp_empty_bytes
        var deliveryProperties = UnsafeMutablePointer<amqp_basic_deliver_t>()
        var messageProperties = UnsafeMutablePointer<amqp_basic_properties_t>()
        var bodySize : size_t = 0
        
        amqp_maybe_release_buffers(channel.connection.internalConnection())
        
        while (messageDone != true) {
            
            // Frame #1
            result = amqp_simple_wait_frame(channel.connection.internalConnection(), frame)
            
            if (result != 0) {
                frame.destroy()
                return message
            }
            
            let methodId = Int(extractAmqpMethod(frame).id)
            var frameType = Int(frame.memory.frame_type)
            
            // AMQP_FRAME_METHOD = 1
            // AMQP_BASIC_DELIVER_METHOD =3932220
            if (frameType != 1 || methodId != 3932220) {
                frame.destroy()
                continue
            }
            
            deliveryProperties = extractMethodDecoded(frame)
            
            // Frame #2
            result = amqp_simple_wait_frame(channel.connection.internalConnection(), frame)
            
            if (result != 0) { return AMQPMessage() }
            
            frameType = Int(frame.memory.frame_type)
            if (frameType != Int(AMQP_FRAME_HEADER)) {
                return AMQPMessage()
            }
            
            messageProperties = extractProperties(frame)
            bodySize = extractBodySize(frame)

            // Don't know how to do this in Swift (if even possible/adivsable)
            
            // Frame #3
            body = parseMessageBody(channel.connection.internalConnection(), frame, bodySize)
            
            message = AMQPMessage(body: body, deliveryProperties: deliveryProperties, messageProperties: messageProperties, receivedAt: NSDate())
            amqp_bytes_free(body)
            
            messageDone = true
        }

        return message
    }
    
}
