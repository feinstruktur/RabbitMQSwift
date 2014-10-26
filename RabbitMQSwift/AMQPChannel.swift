//
//  AMQPChannel.swift
//  RabbitMQSwift
//
//  Created by Carl Gleisner on 2014-08-07.
//  Copyright (c) 2014 Carl Gleisner. All rights reserved.
//

import Foundation

class AMQPChannel : AMQPObject {
    
    var channel : amqp_channel_t = 0
    var connection : AMQPConnection
    var open = false
    
    override init () {
        connection = AMQPConnection()
    }
    
    init(connection: AMQPConnection) {
        self.connection = connection
    }
    
    deinit {
        self.close()
    }
    
    func internalChannel() -> amqp_channel_t {
        return channel
    }
    
    func openChannel(channel: Int) {
        if (open == false && connection.internalConnection() != nil) {
            self.channel = UInt16(channel)

            amqp_channel_open(connection.internalConnection(), self.channel)
        
            if (connection.checkLastOperation("Opening channel")) {
                open = true
            }
        }
    }
    
    func close() {
        if (open == true) {
            amqp_channel_close(connection.internalConnection(), channel, AMQP_REPLY_SUCCESS)
            
            if (connection.checkLastOperation("Closing channel")) {
                
            }
            
            open = false
        }
    }
    
}
