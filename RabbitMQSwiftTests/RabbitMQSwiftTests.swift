//
//  RabbitMQSwiftTests.swift
//  RabbitMQSwiftTests
//
//  Created by Carl Gleisner on 2014-10-26.
//  Copyright (c) 2014 Carl Gleisner. All rights reserved.
//

import Cocoa
import XCTest
import Nimble

/*

These tests expect a default RabbitMQ instance to be running on the host/port given below, with login credentials 'guest / guest'. The easiest way to get there is to run a docker image as follow:

    docker run -d --hostname my-rabbit --name some-rabbit -p 5672:5672 -p 8080:15672 rabbitmq:3-management

*/

let hostname = "dockerhost"
let port: Int32 = 5672
let username = "guest"
let password = "guest"


class RabbitMQSwiftTests: XCTestCase {
    
    func test_lowlevel() {
        let conn = amqp_new_connection()

        // connectToHost
        do {
            let socket = amqp_tcp_socket_new(conn)
            expect(socket).toNot(beNil())
            let status = amqp_socket_open(socket, hostname.cStringUsingEncoding(NSUTF8StringEncoding)!, port)
            expect(status) == AMQP_STATUS_OK.rawValue
        }

        // loginAsUser
        do {
            let channel_max: Int32 = 0
            let frame_max: Int32 = 131072 // 128kB
            let heartbeat: Int32 = 0
            let sasl_method = AMQP_SASL_METHOD_PLAIN
            let user = username.cStringUsingEncoding(NSUTF8StringEncoding)!
            let pass = password.cStringUsingEncoding(NSUTF8StringEncoding)!
            let vhost = "/".cStringUsingEncoding(NSUTF8StringEncoding)!
            let res = amqp_login_with_credentials(conn, vhost, channel_max, frame_max, heartbeat, sasl_method, user, pass)
            expect(res.reply_type.rawValue) == AMQP_RESPONSE_NORMAL.rawValue
        }

        // open channel
        let ch: amqp_channel_t = 42
        do {
            amqp_channel_open(conn, ch)
            let res = amqp_get_rpc_reply(conn)
            expect(res.reply_type.rawValue) == AMQP_RESPONSE_NORMAL.rawValue
        }


        // declare queue
        do {
            let queue = amqp_cstring_bytes("mytest".cStringUsingEncoding(NSUTF8StringEncoding))
            let passive: amqp_boolean_t = 0
            let durable: amqp_boolean_t = 1
            let exclusive: amqp_boolean_t = 0
            let auto_delete: amqp_boolean_t = 0
            let args = amqp_empty_table
            let res = amqp_queue_declare(conn, ch, queue, passive, durable, exclusive, auto_delete, args)
            let mem = res.memory.queue.bytes
            let name = String.fromCString(UnsafePointer<CChar>(mem))
            expect(name) == Optional("mytest")
            do {
                let res = amqp_get_rpc_reply(conn)
                expect(res.reply_type.rawValue) == AMQP_RESPONSE_NORMAL.rawValue
            }
        }


        // declare exchange
        do {
            let name = amqp_cstring_bytes("foo".cStringUsingEncoding(NSUTF8StringEncoding))
            let type = amqp_cstring_bytes("direct".cStringUsingEncoding(NSUTF8StringEncoding))
            let passive: amqp_boolean_t = 0
            let durable: amqp_boolean_t = 0
            let auto_delete: amqp_boolean_t = 0
            let _internal: amqp_boolean_t = 0
            let args = amqp_empty_table
            amqp_exchange_declare(conn, ch, name, type, passive, durable, auto_delete, _internal, args)
            let res = amqp_get_rpc_reply(conn)
            expect(res.reply_type.rawValue) == AMQP_RESPONSE_NORMAL.rawValue
        }


        // publish
        do {
            let ex = amqp_cstring_bytes("".cStringUsingEncoding(NSUTF8StringEncoding))
            let routing = amqp_cstring_bytes("mytest".cStringUsingEncoding(NSUTF8StringEncoding))
            let mandatory: amqp_boolean_t = 0
            let immediate: amqp_boolean_t = 0
            let msg = "sent at \(NSDate())".cStringUsingEncoding(NSUTF8StringEncoding)
            let body = amqp_cstring_bytes(msg!)
            amqp_basic_publish(conn, ch, ex, routing, mandatory, immediate, nil, body)
            let res = amqp_get_rpc_reply(conn)
            expect(res.reply_type.rawValue) == AMQP_RESPONSE_NORMAL.rawValue
        }
        
    }

}
