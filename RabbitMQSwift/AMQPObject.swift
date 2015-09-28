//
//  AMQPObject.swift
//  RabbitMQSwift
//
//  Created by Carl Gleisner on 2014-08-10.
//  Copyright (c) 2014 Carl Gleisner. All rights reserved.
//

import Foundation
import Cocoa

class AMQPObject {
    
    func errorDescriptionForReply(reply : amqp_rpc_reply_t) -> String {
        // TODO: Get string from AMQP-bytes, master the unsafe pointer
        func amqpBytesToString() -> String {
            return ""
        }
        
        var description = ""
        
        switch (reply.reply_type.rawValue) {
        case AMQP_RESPONSE_NORMAL.rawValue:
            description = "Normal response"
            break
        case AMQP_RESPONSE_NONE.rawValue:
            description = "Missing RPC reply type"
            break
        case AMQP_RESPONSE_LIBRARY_EXCEPTION.rawValue:
            let libraryError = Int(reply.library_error)
            if (reply.library_error != 0) {
                description = String.fromCString(amqp_error_string2(reply.library_error))!
            } else {
                description = "End of stream"
            }
            break
        case AMQP_RESPONSE_SERVER_EXCEPTION.rawValue:
            let methodIdValue = Int(reply.reply.id) // TODO: I was unable to put this in nested switch
            if (methodIdValue == 655410) { // The constant AMQP_CONNECTION_CLOSE_METHOD is declared using macros, since Swift has no pre-processor these won't be available
                var amqpConnectionClose = reply.reply.decoded
                // description = amqpBytesToString()
                description = "AMQP_CONNECTION_CLOSE_METHOD"
            } else if (methodIdValue == 1310760) { // AMQP_CHANNEL_CLOSE_METHOD
                var amqpConnectionClose = reply.reply.decoded
                // description = amqpBytesToString()
                description = "AMQP_CHANNEL_CLOSE_METHOD"
            } else {
                description = "Unknown server response exception"
                description = String(format: "Uknown server response exception, id: %d", methodIdValue)
            }
            break
        default:
            description = "Unknown RPC reply type"
        }
        
        return description
    }
}