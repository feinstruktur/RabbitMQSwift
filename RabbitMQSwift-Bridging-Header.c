//
//  RabbitMQSwift-Bridging-Header.c
//  RabbitMQSwift
//
//  Created by Carl Gleisner on 2014-10-26.
//  Copyright (c) 2014 Carl Gleisner. All rights reserved.
//

#include <stdio.h>


#include "RabbitMQSwift-Bridging-Header.h"

// Todo: remember to destroy this!
amqp_envelope_t * CreateEmptyEnvelope() {
    amqp_envelope_t *envelope = malloc(sizeof(amqp_envelope_t));
    return envelope;
}

amqp_basic_properties_t * extractProperties(amqp_frame_t * frame) {
    // return (amqp_basic_properties_t *) &frame->payload.properties;
    // return frame->payload.properties;
    return (amqp_basic_properties_t*) frame->payload.properties.decoded;
}

protocol_header *extractProtocolHeader(amqp_frame_t * frame) {
    return &frame->payload.protocol_header;
}

amqp_method_t extractAmqpMethod(amqp_frame_t * frame) {
    return frame->payload.method;
}

amqp_basic_deliver_t * extractMethodDecoded(amqp_frame_t * frame) {
    return frame->payload.method.decoded;
}

size_t extractBodySize(amqp_frame_t * frame) {
    return (size_t) frame->payload.properties.body_size;
}

size_t extractBodyFragmentLen(amqp_frame_t * frame) {
    return frame->payload.body_fragment.len;
}

amqp_bytes_t * extractBodyFragment(amqp_frame_t * frame) {
    return (amqp_bytes_t *) &frame->payload.body_fragment.bytes;
}

const char * nullTerminatedString() {
    return "HAJ";
}

amqp_bytes_t parseMessageBody(amqp_connection_state_t connection, amqp_frame_t * frame, size_t body_size) {
    size_t received_bytes = 0;
    amqp_bytes_t body = amqp_bytes_malloc(body_size);
    
    while (received_bytes < body_size) {
        int res = amqp_simple_wait_frame(connection, frame);
        
        if (res != 0) { return amqp_empty_bytes; }
        if (frame->frame_type != AMQP_FRAME_BODY) { return amqp_empty_bytes; }
        
        received_bytes += frame->payload.body_fragment.len;
        
        memcpy(body.bytes, frame->payload.body_fragment.bytes, frame->payload.body_fragment.len);
    }
    
    return body;
}

amqp_rpc_reply_t amqp_login_with_credentials(amqp_connection_state_t state, char const *vhost,
                                             int channel_max, int frame_max, int heartbeat,
                                             amqp_sasl_method_enum sasl_method, const char * user, const char * password) {
    return amqp_login(state, vhost, channel_max, frame_max, heartbeat, sasl_method, user, password);
}