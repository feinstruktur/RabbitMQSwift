//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include "amqp_tcp_socket.h"
#include "amqp.h"
#include "amqp_framing.h"

amqp_envelope_t * CreateEmptyEnvelope();

// Some constants are defined using more complex macros than Swift can manange without any pre-processor
// #define AMQP_BASIC_DELIVER_METHOD 3932220

// Due to Swift not managing struct union
typedef struct {
    uint16_t class_id;    /**< the class for the properties */
    uint64_t body_size;   /**< size of the body in bytes */
    void *decoded;        /**< the decoded properties */
    amqp_bytes_t raw;     /**< amqp-encoded properties structure */
} frame_properties;           /**< message header, a.k.a., properties,
                               use if frame_type == AMQP_FRAME_HEADER */

typedef struct {
    uint8_t transport_high;           /**< @internal first byte of handshake */
    uint8_t transport_low;            /**< @internal second byte of handshake */
    uint8_t protocol_version_major;   /**< @internal third byte of handshake */
    uint8_t protocol_version_minor;   /**< @internal fourth byte of handshake */
} protocol_header;    /**< Used only when doing the initial handshake with the broker,
                       don't use otherwise */

amqp_basic_properties_t * extractProperties(amqp_frame_t * frame);
protocol_header *extractProtocolHeader(amqp_frame_t * frame);
amqp_method_t extractAmqpMethod(amqp_frame_t * frame);
amqp_basic_deliver_t * extractMethodDecoded(amqp_frame_t * frame);
size_t extractBodySize(amqp_frame_t * frame);
size_t extractBodyFragmentLen(amqp_frame_t * frame);
amqp_bytes_t * extractBodyFragment(amqp_frame_t * frame);

const char * nullTerminatedString();

amqp_bytes_t parseMessageBody(amqp_connection_state_t connection, amqp_frame_t * frame, size_t body_size);

amqp_rpc_reply_t amqp_login_with_credentials(amqp_connection_state_t state, char const *vhost,
                                             int channel_max, int frame_max, int heartbeat,
                                             amqp_sasl_method_enum sasl_method, const char * user, const char * password);