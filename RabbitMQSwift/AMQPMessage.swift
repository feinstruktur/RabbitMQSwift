//
//  AMQPMessage.swift
//  RabbitMQSwift
//
//  Created by Carl Gleisner on 2014-08-10.
//  Copyright (c) 2014 Carl Gleisner. All rights reserved.
//

import Foundation

class AMQPMessage : AMQPObject {
    
    var body : String = ""
    
    // from properties
    var contentType : String = ""
    var contentEncoding : String = ""
    var headers : amqp_table_t = amqp_empty_table
    var deliveryMode : Int = 0
    var priority : Int = 0
    var correlationId : String = ""
    var replyToQueueName : String = ""
    var expiration : String = ""
    var messageId : String = ""
    var timestamp : UInt64 = 0
    var type : String = ""
    var userId : String = ""
    var appId : String = ""
    var clusterId : String = ""
    
    var consumerTag : String = ""
    var deliveryTag : UInt64 = 0
    var redelivered : Bool = false
    var exchangeName : String = ""
    var routingKey : String = ""
    
    var read : Bool = false
    var receivedAt : NSDate = NSDate()
    
    override init() {

    }

    init(body : amqp_bytes_t, deliveryProperties : UnsafeMutablePointer<amqp_basic_deliver_t>,
        messageProperties : UnsafeMutablePointer<amqp_basic_properties_t>, receivedAt : NSDate) {
            func fromAmqpBytes(amqpBytes : amqp_bytes_t) -> String {
                let data = NSData(bytes: amqpBytes.bytes, length: Int(amqpBytes.len))
                return NSString(data: data, encoding: NSUTF8StringEncoding)!
            }
            
            func checkFlag(flags : UInt32, mask : UInt32) -> Bool {
                if ((flags & mask) != 0) {
                    return true
                }
                
                return false
            }
            
            // if !deliveryProperties || !messageProperties, return nil
            if (deliveryProperties == nil || messageProperties == nil) {
                return
            }

            self.body = fromAmqpBytes(body)
            
            // Delivery properties
            self.consumerTag = fromAmqpBytes(deliveryProperties.memory.consumer_tag)
            self.deliveryTag = UInt64(deliveryProperties.memory.delivery_tag)
            self.redelivered = (deliveryProperties.memory.redelivered == 1)
            self.exchangeName = fromAmqpBytes(deliveryProperties.memory.exchange)
            self.routingKey = fromAmqpBytes(deliveryProperties.memory.routing_key)
            
            // Message properties
            let flags = UInt32(messageProperties.memory._flags)
            let flagType = UInt32(AMQP_BASIC_CONTENT_TYPE_FLAG)
            
            if (checkFlag(flags, UInt32(AMQP_BASIC_CONTENT_TYPE_FLAG))) {
                self.contentType = fromAmqpBytes(messageProperties.memory.content_type)
                println(self.contentType)
            }
            
            if(checkFlag(flags, UInt32(AMQP_BASIC_CONTENT_ENCODING_FLAG))) {
                contentEncoding = fromAmqpBytes(messageProperties.memory.content_encoding)
            }
            
            if(checkFlag(flags, UInt32(AMQP_BASIC_HEADERS_FLAG))) {
                headers = messageProperties.memory.headers
            }
            
            if(checkFlag(flags, UInt32(AMQP_BASIC_DELIVERY_MODE_FLAG))) {
                deliveryMode = Int(messageProperties.memory.delivery_mode)
            }
            
            if(checkFlag(flags, UInt32(AMQP_BASIC_PRIORITY_FLAG))) {
                priority = Int(messageProperties.memory.priority)
            }
            
            if(checkFlag(flags, UInt32(AMQP_BASIC_CORRELATION_ID_FLAG))) {
                correlationId = fromAmqpBytes(messageProperties.memory.correlation_id)
            }
            
            if(checkFlag(flags, UInt32(AMQP_BASIC_REPLY_TO_FLAG))) {
                replyToQueueName = fromAmqpBytes(messageProperties.memory.reply_to)
            }
            
            if(checkFlag(flags, UInt32(AMQP_BASIC_EXPIRATION_FLAG))) {
                expiration = fromAmqpBytes(messageProperties.memory.expiration)
            }
            
            if(checkFlag(flags, UInt32(AMQP_BASIC_MESSAGE_ID_FLAG))) {
                messageId = fromAmqpBytes(messageProperties.memory.message_id)
            }
            
            if(checkFlag(flags, UInt32(AMQP_BASIC_TIMESTAMP_FLAG))) {
                timestamp = messageProperties.memory.timestamp
            }
            
            if(checkFlag(flags, UInt32(AMQP_BASIC_TYPE_FLAG))) {
                type = fromAmqpBytes(messageProperties.memory.type)
            }
            
            if(checkFlag(flags, UInt32(AMQP_BASIC_USER_ID_FLAG))) {
                userId = fromAmqpBytes(messageProperties.memory.user_id)
            }
            
            if(checkFlag(flags, UInt32(AMQP_BASIC_APP_ID_FLAG))) {
                appId = fromAmqpBytes(messageProperties.memory.app_id)
            }
            
            if(checkFlag(flags, UInt32(AMQP_BASIC_CLUSTER_ID_FLAG))) {
                clusterId = fromAmqpBytes(messageProperties.memory.cluster_id)
            }
            
            self.read = false
            self.receivedAt = NSDate()
    }

}