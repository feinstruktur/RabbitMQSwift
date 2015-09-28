//
//  AMQPConnection.swift
//  RabbitMQSwift
//
//  Created by Carl Gleisner on 2014-08-06.
//  Copyright (c) 2014 Carl Gleisner. All rights reserved.
//

import Cocoa
import Foundation


class AMQPConnection : AMQPObject {

    private var connection : COpaquePointer // amqp_connection_state_t
    private var socket : COpaquePointer // amqp_socket_t
    private var nextChannel = 1
    
    private var connected = false
    private var loggedIn = false
    private var used = false
    
    override init() {
        connection = amqp_new_connection()
        socket = COpaquePointer.null()
    }
    
    deinit {
        self.disconnect()
    }
    
    func connectToHost(host: NSString, port: Int) {
        if (used) {
            NSException(name: "Re-used connection", reason: "Trying to re-connect on a connection that has already been used.", userInfo: nil).raise()
            return
        }
        
        if (connected != true) {                
            socket = amqp_tcp_socket_new(connection)
            
            if (socket == nil) {
                print("Failed to create socket.")
                return
            }
            
            let socketStatus = Int(amqp_socket_open(socket, host.UTF8String, Int32(port)))
            
            if (socketStatus < 0) {
                print("Failed to open socket.")
                return
            }
            
            connected = true
            
            
        } else {
            NSException(name: "Redundant connection attempt", reason: "Trying to connect to host when already connected.", userInfo: nil).raise()
        }
    }
    
    func loginAsUser(username: NSString, password: NSString, vhost: String) {
        if (connected) {
            if (loggedIn == false) {
                
                // TODO: Wrap the login function in the bridging header
//                var reply = amqp_login_with_credentials(self.connection, vhost, CInt(0), CInt(131072), CInt(0), AMQP_SASL_METHOD_PLAIN, username.UTF8String, password.UTF8String)
                    let reply = amqp_login_with_credentials(self.internalConnection(), vhost, CInt(0), CInt(131072), CInt(0), AMQP_SASL_METHOD_PLAIN, username.UTF8String, password.UTF8String)
                
                if (reply.reply_type.rawValue != AMQP_RESPONSE_NORMAL.rawValue) {
                    print("Error while logging in.")
                    print(self.errorDescriptionForReply(reply))
                    return
                } else {
                    loggedIn = true
                }
                
            } else {
                NSException(name: "Login error", reason: "Trying to login when already logged in", userInfo: nil).raise()
                return
            }
            
        } else {
            NSException(name: "Login error", reason: "Trying to login without being connected to host", userInfo: nil).raise()
            return
        }
    }
    
    func loginAsUser(username: NSString, password: NSString) {
        loginAsUser(username, password: password, vhost: "/")
    }
    
    func disconnect() {
        if (connected && connection != COpaquePointer.null()) {
            let reply : amqp_rpc_reply_t = amqp_connection_close(self.connection, CInt(AMQP_REPLY_SUCCESS))
        
            if (reply.reply_type.rawValue != AMQP_RESPONSE_NORMAL.rawValue) {
                print("Error while disconnecting from host")
            }
        
            amqp_destroy_connection(connection)
            connection = COpaquePointer.null() // TODO: Needed?
            
            loggedIn = false
            connected = false
            used = true
        }
    }
    
    func openChannel() -> AMQPChannel {
        let channel = AMQPChannel(connection: self)
        channel.openChannel(nextChannel)
        
        nextChannel++
        
        return channel
    }
    
    func internalConnection() -> amqp_connection_state_t {
        if (connection == COpaquePointer.null()) {
            print("Warning! Tried to get internal connection while this was null.")
        }
        
        return connection
    }
    
    func isConnected() -> Bool {
        return connected
    }
    
    func checkLastOperation(context: NSString) -> Bool {
        if (connected) {
            let reply : amqp_rpc_reply_t = amqp_get_rpc_reply(connection)
            
            if (reply.reply_type.rawValue != AMQP_RESPONSE_NORMAL.rawValue) {
                print(String(format: "Failed operation: %@, Error: %@", context, self.errorDescriptionForReply(reply)))
                return false
            }
        } else {
            print("Cannot check last operation if not connected.")
            return false
        }
        
        return true
    }

}
