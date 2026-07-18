Caller Log
[InfobipCallKit][Center] InfobipCallCenter initialized (pushConfigId=1ce41cec-c13a-41b2-80dc-de54cf62d6bf)
[InfobipCallKit][Client] activateCallService()
[InfobipCallKit][CallService] CallKit activated
[InfobipCallKit][Client] enablePushNotifications(credentials:)
[InfobipCallKit][CallService] host provided VoIP push credentials
[InfobipCallKit][Client] registerSubscriber(identity: driver, hasImage: true)
[InfobipCallKit][CallService] registered subscriber driver displayName=Nguyễn Văn Nam hasImage=true
[InfobipCallKit][Client] registerForIncomingCalls()
[InfobipCallKit][CallService] enablePushNotification status=success message=Successfully registered for notifications with device: E2FD063DBFC1A1856A2E585C8BB5DBC2B79C9C03A2ACE9A46CEFCC72F268504D
tcp_input [C1.1.1.1:3] flags=[R] seq=1979754986, ack=0, win=0 state=LAST_ACK rcv_nxt=1979754986, snd_una=3063182271
tcp_input [C2.1.1.1:3] flags=[R] seq=383735509, ack=0, win=0 state=LAST_ACK rcv_nxt=383735509, snd_una=1295622146
[InfobipCallKit][Client] startOutgoingCall(destinationIdentity: customer)
[InfobipCallKit][CallService] makeCall → customer callee=Trần Thị Hoa customData keys=["avatarUrl", "displayName"]
[InfobipCallKit][Client] event → started(InfobipCallKit.CallSession(id: "72a7bd33-c874-4aac-b874-e2c173c5061e", direction: InfobipCallKit.CallSession.Direction.outgoing, status: InfobipCallKit.CallSession.Status.connecting, counterpartIdentity: "customer", counterpartDisplayName: "Trần Thị Hoa", counterpartAvatarURL: Optional(https://i.pravatar.cc/300?u=gsmcall-customer), isMuted: false, isSpeakerOn: false, durationSeconds: 0, networkQuality: nil, endReason: nil))
[Example] call started → Trần Thị Hoa (outgoing)
[InfobipCallKit][FreeCallVM] event=audioRouteChanged(InfobipCallKit.AudioRouteOption(id: "Built-In Microphone#0", name: "iPhone", kind: InfobipCallKit.AudioRouteOption.Kind.builtin, isActive: true)) phase=connecting direction=outgoing
[InfobipCallKit][Client] event → audioRouteChanged(name: "iPhone")
[Example] audio route: iPhone
[INFO] Socket viability changed, viable: True
[INFO] Connected to Portunus.
[INFO] Received message from Portunus: {"event":"registered","identity":"driver","iceServers":[{"urls":"stun:stun.infobip.com:443"},{"urls":"turns:munm3.turn.infobip.com:443?transport=tcp","credential":"2YvBNpA5qToWeBlHKi6XNNQ9iTA=","username":"1784109367:driver"},{"urls":"turn:185.255.8.179:443?transport=tcp","credential":"2YvBNpA5qToWeBlHKi6XNNQ9iTA=","username":"1784109367:driver"}],"apiUrl":"pd11gl.api-id.infobip.com","logLevel":"WARNING","instanceHash":"0af259c2afda2c947db52b7f69f949c23afdc725539e8335f751ede4910658c0","transaction":"88cfc526-f4fc-4223-877f-5eb3927c90da"}
[INFO] Registered as driver successfully.
[INFO] peerConnection should negotiate
[INFO] peerConnection new signaling state: haveLocalOffer
[INFO] Sending {"callsConfigurationId":"WEBRTC","platform":{},"media":{"video":{"camera":false},"audio":{"muted":false}},"internalCustomData":{"type":"WEBRTC","withDialog":"true","to":"customer"},"videoMode":"PRESENTATION","destination":"customer","action":"application_call","description":{"type":"offer","sdp":"v=0\r\no=- 3102423823683446356 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=group:BUNDLE 0\r\na=extmap-allow-mixed\r\na=msid-semantic: WMS\r\nm=audio 9 UDP\/TLS\/RTP\/SAVPF 111 63 9 0 8 13 110 126\r\nc=IN IP4 0.0.0.0\r\na=rtcp:9 IN IP4 0.0.0.0\r\na=ice-ufrag:zJX7\r\na=ice-pwd:W+r9UvBcEMo57FYlNO3FuyvD\r\na=ice-options:trickle renomination\r\na=fingerprint:sha-256 CA:F4:22:E3:90:5C:4B:B6:57:23:FA:4A:54:62:12:D8:77:E1:28:77:B5:47:42:7D:51:C4:C9:8D:46:1A:04:18\r\na=setup:actpass\r\na=mid:0\r\na=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level\r\na=extmap:2 http:\/\/www.webrtc.org\/experiments\/rtp-hdrext\/abs-send-time\r\na=extmap:3 http:\/\/www.ietf.org\/id\/draft-holmer-rmcat-transport-wide-cc-extensions
[INFO] peerConnection new gathering state: gathering
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:3244741508 1 udp 2121277183 192.0.0.6 58644 typ host generation 0 ufrag zJX7 network-id 10 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"}} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"candidate":"candidate:3848382298 1 udp 2121801471 30.53.17.79 50924 typ host generation 0 ufrag zJX7 network-id 16 network-cost 900","sdpMLineIndex":0,"sdpMid":"0"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMid":"0","candidate":"candidate:3848382298 1 udp 2122260223 30.53.17.79 57988 typ host generation 0 ufrag zJX7 network-id 17 network-cost 50","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMid":"0","candidate":"candidate:3244741508 1 udp 2121473791 192.0.0.6 64389 typ host generation 0 ufrag zJX7 network-id 5 network-cost 50","sdpMLineIndex":0},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:3848382298 1 udp 2121408255 30.53.17.79 61699 typ host generation 0 ufrag zJX7 network-id 8 network-cost 50"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"sdpMid":"0","candidate":"candidate:288866672 1 udp 2122199807 fdea:e111:ce6b:0:c85:bdc8:3238:f888 50996 typ host generation 0 ufrag zJX7 network-id 3 network-cost 10","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"ice":{"candidate":"candidate:3848382298 1 udp 2121342719 30.53.17.79 62242 typ host generation 0 ufrag zJX7 network-id 9 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"candidate":"candidate:112524767 1 udp 2121867007 11.234.119.156 57240 typ host generation 0 ufrag zJX7 network-id 14 network-cost 900","sdpMLineIndex":0,"sdpMid":"0"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"candidate":"candidate:2275259511 1 udp 2121741055 fd74:6572:6d6e:7573:c:4020:81cf:2a1a 53404 typ host generation 0 ufrag zJX7 network-id 6 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"sdpMid":"0","candidate":"candidate:2445625691 1 udp 2121675519 fd74:6572:6d6e:7573:d:4020:81cf:2a1a 60196 typ host generation 0 ufrag zJX7 network-id 7 network-cost 50","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:1629018477 1 udp 2121935103 2401:d800:5ee6:c593:2dfa:61e0:2c98:f4c 50335 typ host generation 0 ufrag zJX7 network-id 15 network-cost 900"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:3725535367 1 udp 2122131711 2402:800:61d1:ee99:e182:ec59:4b96:21c4 63348 typ host generation 0 ufrag zJX7 network-id 2 network-cost 10"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:635654482 1 udp 2122063615 192.168.1.73 54610 typ host generation 0 ufrag zJX7 network-id 1 network-cost 10"},"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:1529656266 1 tcp 1518083839 192.168.1.73 60890 typ host tcptype passive generation 0 ufrag zJX7 network-id 1 network-cost 10","sdpMid":"0","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"ice":{"candidate":"candidate:2611889602 1 tcp 1518280447 30.53.17.79 60889 typ host tcptype passive generation 0 ufrag zJX7 network-id 17 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:3215536412 1 tcp 1517297407 192.0.0.6 60891 typ host tcptype passive generation 0 ufrag zJX7 network-id 10 network-cost 50"},"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"ice":{"candidate":"candidate:2021334855 1 tcp 1517887231 11.234.119.156 60892 typ host tcptype passive generation 0 ufrag zJX7 network-id 14 network-cost 900","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:2611889602 1 tcp 1517821695 30.53.17.79 60893 typ host tcptype passive generation 0 ufrag zJX7 network-id 16 network-cost 900","sdpMid":"0","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:3215536412 1 tcp 1517494015 192.0.0.6 60894 typ host tcptype passive generation 0 ufrag zJX7 network-id 5 network-cost 50"},"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"ice":{"candidate":"candidate:2611889602 1 tcp 1517428479 30.53.17.79 60895 typ host tcptype passive generation 0 ufrag zJX7 network-id 8 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:2611889602 1 tcp 1517362943 30.53.17.79 60896 typ host tcptype passive generation 0 ufrag zJX7 network-id 9 network-cost 50","sdpMid":"0","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:1878533096 1 tcp 1518220031 fdea:e111:ce6b:0:c85:bdc8:3238:f888 60897 typ host tcptype passive generation 0 ufrag zJX7 network-id 3 network-cost 10"},"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"ice":{"candidate":"candidate:4182922991 1 tcp 1517761279 fd74:6572:6d6e:7573:c:4020:81cf:2a1a 60899 typ host tcptype passive generation 0 ufrag zJX7 network-id 6 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMid":"0","candidate":"candidate:2696989215 1 tcp 1518151935 2402:800:61d1:ee99:e182:ec59:4b96:21c4 60900 typ host tcptype passive generation 0 ufrag zJX7 network-id 2 network-cost 10","sdpMLineIndex":0},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMid":"0","candidate":"candidate:534199285 1 tcp 1517955327 2401:d800:5ee6:c593:2dfa:61e0:2c98:f4c 60898 typ host tcptype passive generation 0 ufrag zJX7 network-id 15 network-cost 900","sdpMLineIndex":0},"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:4010453955 1 tcp 1517695743 fd74:6572:6d6e:7573:d:4020:81cf:2a1a 60901 typ host tcptype passive generation 0 ufrag zJX7 network-id 7 network-cost 50"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMid":"0","candidate":"candidate:1696146427 1 udp 1685855999 171.231.207.196 25306 typ srflx raddr 192.168.1.73 rport 54610 generation 0 ufrag zJX7 network-id 1 network-cost 10","sdpMLineIndex":0},"action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"action":"ice_candidate","ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:4287016364 1 udp 24911871 185.255.8.179 50305 typ relay raddr 171.231.207.196 rport 30299 generation 0 ufrag zJX7 network-id 1 network-cost 10"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMLineIndex":0,"candidate":"candidate:4213688799 1 udp 8134911 185.255.8.178 61835 typ relay raddr 171.231.207.196 rport 20254 generation 0 ufrag zJX7 network-id 1 network-cost 10","sdpMid":"0"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:3346705045 1 udp 1685659391 171.255.66.99 5993 typ srflx raddr 11.234.119.156 rport 57240 generation 0 ufrag zJX7 network-id 14 network-cost 900","sdpMLineIndex":0,"sdpMid":"0"}} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"candidate":"candidate:4287016364 1 udp 24715263 185.255.8.179 52388 typ relay raddr 171.255.66.99 rport 27478 generation 0 ufrag zJX7 network-id 14 network-cost 900","sdpMLineIndex":0,"sdpMid":"0"}} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:4213688799 1 udp 7938303 185.255.8.178 56983 typ relay raddr 171.255.66.99 rport 19798 generation 0 ufrag zJX7 network-id 14 network-cost 900","sdpMid":"0","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Received message from Portunus: {"event":"ringing","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","customData":{"avatarUrl":"https://i.pravatar.cc/300?img=12","displayName":"Nguyễn Văn Nam"},"internalCustomData":{"type":"WEBRTC","withDialog":"true","to":"customer"},"transaction":"fea6227d-5f64-4158-bbb3-64666328f93c"}
[InfobipCallKit][FreeCallVM] event=ringing phase=connecting direction=outgoing
[InfobipCallKit][Client] event → ringing
[Example] ringing

OSLOG-50DEF794-AD0D-47DA-B6B5-7766B8A52351 7 80 L 59 {t:1784080642.457859}	[INFO] Received message from Portunus: {"event":"call_response","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","isEarlyMedia":false,"description":{"type":"answer","sdp":"v=0\r\no=Infobip 1784061808 1784061809 IN IP4 81.23.249.61\r\ns=Infobip\r\nt=0 0\r\na=extmap-allow-mixed\r\na=ice-lite\r\na=fingerprint:sha-256 45:F4:34:CC:CC:8E:D4:FF:9F:09:D2:09:E4:DD:62:88:57:2A:69:65:B3:60:AC:EF:A7:F4:7E:14:82:E3:0F:3B\r\na=ice-options:trickle\r\na=msid-semantic: WMS *\r\na=group:BUNDLE 0\r\nm=audio 9 UDP/TLS/RTP/SAVPF 111 110 13\r\nc=IN IP4 81.23.249.61\r\na=rtpmap:111 opus/48000/2\r\na=rtpmap:110 telephone-event/48000\r\na=rtpmap:13 CN/8000\r\na=fmtp:111 useinbandfec=1; minptime=10\r\na=fmtp:110 0-15\r\na=setup:active\r\na=mid:0\r\na=msid:janus janus0\r\na=ptime:20\r\na=sendrecv\r\na=ice-ufrag:iFVJ\r\na=ice-pwd:fLiQxJQvouw0JbIalMNRpq\r\na=candidate:1 1 udp 2015363327 81.23.249.61 27582 typ host\r\na=candidate:2 1 udp 2015363583 81.23.249.61 28651 typ host\r\na=end-of-candidates\r\na=ice-options:trickle\r\na=ssrc:81049
Logging Error: Failed to receive 1 log messages. Please review standard output for possible log message content.
[INFO] peerConnection new signaling state: stable
[INFO] audio peerConnection new connection state: checking
[INFO] Received message from Portunus: {"event":"joined_video_call"}
[INFO] Received message from Portunus: {"event":"dialog_established","id":"4eaac0db-9b7d-4e6d-900c-e800abc977a5","participants":[{"streams":{},"endpoint":{"type":"WEBRTC","identity":"driver","displayName":"Nguyễn Văn Nam"},"media":{"audio":{"muted":false,"deaf":false,"userMuted":false},"video":{"screenShare":false,"camera":false,"blind":false}},"state":"JOINED","disconnected":false,"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","role":null},{"streams":{},"endpoint":{"type":"WEBRTC","identity":"customer"},"media":{"audio":{"muted":false,"deaf":false,"userMuted":false},"video":{"screenShare":false,"camera":false,"blind":false}},"state":"JOINED","disconnected":false,"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","role":null}]}
[INFO] Received message from Portunus: {"event":"joined_video_conference"}
[INFO] Received message from Portunus: {"event":"setup_data_channel","description":{"type":"offer","sdp":"v=0\r\no=- 1784080642693171 1 IN IP4 81.23.249.62\r\ns=Janus TextRoom plugin\r\nt=0 0\r\na=group:BUNDLE 0\r\na=ice-options:trickle\r\na=fingerprint:sha-256 45:F4:34:CC:CC:8E:D4:FF:9F:09:D2:09:E4:DD:62:88:57:2A:69:65:B3:60:AC:EF:A7:F4:7E:14:82:E3:0F:3B\r\na=extmap-allow-mixed\r\na=msid-semantic: WMS *\r\na=ice-lite\r\nm=application 9 UDP/DTLS/SCTP webrtc-datachannel\r\nc=IN IP4 81.23.249.62\r\na=sendrecv\r\na=mid:0\r\na=sctp-port:5000\r\na=ice-ufrag:Lwvs\r\na=ice-pwd:SamsiUhj4S+KEqs4XMP2Wk\r\na=ice-options:trickle\r\na=setup:actpass\r\na=candidate:1 1 udp 2015363327 81.23.249.62 28230 typ host\r\na=candidate:2 1 udp 2015363583 81.23.249.62 37704 typ host\r\na=end-of-candidates\r\n"},"id":"4eaac0db-9b7d-4e6d-900c-e800abc977a5@1456863.infobip.com"}
[INFO] audio peerConnection new connection state: connected
[INFO] Sending {"action":"ice_candidate_pair_selected","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","selectedCandidatePair":{"remote":{"ip":"81.23.249.61","type":"host","protocol":"udp","port":27582},"local":{"ip":"171.231.207.196","type":"prflx","protocol":"udp","port":11653}}} to Infobip Gateway.
[InfobipCallKit][FreeCallVM] event=established phase=ringing direction=outgoing
[InfobipCallKit][Client] event → established
[Example] established
[InfobipCallKit][FreeCallVM] event=audioRouteChanged(InfobipCallKit.AudioRouteOption(id: "Built-In Microphone#0", name: "iPhone", kind: InfobipCallKit.AudioRouteOption.Kind.builtin, isActive: true)) phase=established direction=outgoing
[InfobipCallKit][Client] event → audioRouteChanged(name: "iPhone")
[Example] audio route: iPhone
[INFO] Sending {"reason":"Normal call clearing","action":"hangup","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
           SessionCore.mm:546   Failed to set properties, error: '!pri'
[WARNING] Failed to set normal Audio mode after call: The operation couldn’t be completed. (OSStatus error 561017449.)
[INFO] audio peerConnection new connection state: closed
[INFO] peerConnection new signaling state: closed
[InfobipCallKit][ActiveCall] onHangup code=10000 name=NORMAL_HANGUP
[InfobipCallKit][FreeCallVM] event=hangup(InfobipCallKit.CallEndReason(code: 10000, name: "NORMAL_HANGUP", message: "The call ended due to a hangup initiated by the caller, callee, or API.", isError: false)) phase=established direction=outgoing
[InfobipCallKit][FreeCallVM] finish wasEstablished=true local=true route=backToHome delay=0.0
[InfobipCallKit][CallKit] reportCallEnded uuid=72A7BD33-C874-4AAC-B874-E2C173C5061E reason=2
[InfobipCallKit][Client] event → ended(InfobipCallKit.CallEndReason(code: 10000, name: "NORMAL_HANGUP", message: "The call ended due to a hangup initiated by the caller, callee, or API.", isError: false))
[Example] call ended: NORMAL_HANGUP (code 10000, isError: false) — The call ended due to a hangup initiated by the caller, callee, or API.
[InfobipCallKit][FreeCallVM] triggering route backToHome
[INFO] Successfully submitted 10 logs
tcp_input [C4.1.1.1:3] flags=[R] seq=98426889, ack=0, win=0 state=LAST_ACK rcv_nxt=98426889, snd_una=2203007579[InfobipCallKit][Center] InfobipCallCenter initialized (pushConfigId=1ce41cec-c13a-41b2-80dc-de54cf62d6bf)
[InfobipCallKit][Client] activateCallService()
[InfobipCallKit][CallService] CallKit activated
[InfobipCallKit][Client] enablePushNotifications(credentials:)
[InfobipCallKit][CallService] host provided VoIP push credentials
[InfobipCallKit][Client] registerSubscriber(identity: driver, hasImage: true)
[InfobipCallKit][CallService] registered subscriber driver displayName=Nguyễn Văn Nam hasImage=true
[InfobipCallKit][Client] registerForIncomingCalls()
[InfobipCallKit][CallService] enablePushNotification status=success message=Successfully registered for notifications with device: E2FD063DBFC1A1856A2E585C8BB5DBC2B79C9C03A2ACE9A46CEFCC72F268504D
tcp_input [C1.1.1.1:3] flags=[R] seq=1979754986, ack=0, win=0 state=LAST_ACK rcv_nxt=1979754986, snd_una=3063182271
tcp_input [C2.1.1.1:3] flags=[R] seq=383735509, ack=0, win=0 state=LAST_ACK rcv_nxt=383735509, snd_una=1295622146
[InfobipCallKit][Client] startOutgoingCall(destinationIdentity: customer)
[InfobipCallKit][CallService] makeCall → customer callee=Trần Thị Hoa customData keys=["avatarUrl", "displayName"]
[InfobipCallKit][Client] event → started(InfobipCallKit.CallSession(id: "72a7bd33-c874-4aac-b874-e2c173c5061e", direction: InfobipCallKit.CallSession.Direction.outgoing, status: InfobipCallKit.CallSession.Status.connecting, counterpartIdentity: "customer", counterpartDisplayName: "Trần Thị Hoa", counterpartAvatarURL: Optional(https://i.pravatar.cc/300?u=gsmcall-customer), isMuted: false, isSpeakerOn: false, durationSeconds: 0, networkQuality: nil, endReason: nil))
[Example] call started → Trần Thị Hoa (outgoing)
[InfobipCallKit][FreeCallVM] event=audioRouteChanged(InfobipCallKit.AudioRouteOption(id: "Built-In Microphone#0", name: "iPhone", kind: InfobipCallKit.AudioRouteOption.Kind.builtin, isActive: true)) phase=connecting direction=outgoing
[InfobipCallKit][Client] event → audioRouteChanged(name: "iPhone")
[Example] audio route: iPhone
[INFO] Socket viability changed, viable: True
[INFO] Connected to Portunus.
[INFO] Received message from Portunus: {"event":"registered","identity":"driver","iceServers":[{"urls":"stun:stun.infobip.com:443"},{"urls":"turns:munm3.turn.infobip.com:443?transport=tcp","credential":"2YvBNpA5qToWeBlHKi6XNNQ9iTA=","username":"1784109367:driver"},{"urls":"turn:185.255.8.179:443?transport=tcp","credential":"2YvBNpA5qToWeBlHKi6XNNQ9iTA=","username":"1784109367:driver"}],"apiUrl":"pd11gl.api-id.infobip.com","logLevel":"WARNING","instanceHash":"0af259c2afda2c947db52b7f69f949c23afdc725539e8335f751ede4910658c0","transaction":"88cfc526-f4fc-4223-877f-5eb3927c90da"}
[INFO] Registered as driver successfully.
[INFO] peerConnection should negotiate
[INFO] peerConnection new signaling state: haveLocalOffer
[INFO] Sending {"callsConfigurationId":"WEBRTC","platform":{},"media":{"video":{"camera":false},"audio":{"muted":false}},"internalCustomData":{"type":"WEBRTC","withDialog":"true","to":"customer"},"videoMode":"PRESENTATION","destination":"customer","action":"application_call","description":{"type":"offer","sdp":"v=0\r\no=- 3102423823683446356 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=group:BUNDLE 0\r\na=extmap-allow-mixed\r\na=msid-semantic: WMS\r\nm=audio 9 UDP\/TLS\/RTP\/SAVPF 111 63 9 0 8 13 110 126\r\nc=IN IP4 0.0.0.0\r\na=rtcp:9 IN IP4 0.0.0.0\r\na=ice-ufrag:zJX7\r\na=ice-pwd:W+r9UvBcEMo57FYlNO3FuyvD\r\na=ice-options:trickle renomination\r\na=fingerprint:sha-256 CA:F4:22:E3:90:5C:4B:B6:57:23:FA:4A:54:62:12:D8:77:E1:28:77:B5:47:42:7D:51:C4:C9:8D:46:1A:04:18\r\na=setup:actpass\r\na=mid:0\r\na=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level\r\na=extmap:2 http:\/\/www.webrtc.org\/experiments\/rtp-hdrext\/abs-send-time\r\na=extmap:3 http:\/\/www.ietf.org\/id\/draft-holmer-rmcat-transport-wide-cc-extensions
[INFO] peerConnection new gathering state: gathering
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:3244741508 1 udp 2121277183 192.0.0.6 58644 typ host generation 0 ufrag zJX7 network-id 10 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"}} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"candidate":"candidate:3848382298 1 udp 2121801471 30.53.17.79 50924 typ host generation 0 ufrag zJX7 network-id 16 network-cost 900","sdpMLineIndex":0,"sdpMid":"0"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMid":"0","candidate":"candidate:3848382298 1 udp 2122260223 30.53.17.79 57988 typ host generation 0 ufrag zJX7 network-id 17 network-cost 50","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMid":"0","candidate":"candidate:3244741508 1 udp 2121473791 192.0.0.6 64389 typ host generation 0 ufrag zJX7 network-id 5 network-cost 50","sdpMLineIndex":0},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:3848382298 1 udp 2121408255 30.53.17.79 61699 typ host generation 0 ufrag zJX7 network-id 8 network-cost 50"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"sdpMid":"0","candidate":"candidate:288866672 1 udp 2122199807 fdea:e111:ce6b:0:c85:bdc8:3238:f888 50996 typ host generation 0 ufrag zJX7 network-id 3 network-cost 10","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"ice":{"candidate":"candidate:3848382298 1 udp 2121342719 30.53.17.79 62242 typ host generation 0 ufrag zJX7 network-id 9 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"candidate":"candidate:112524767 1 udp 2121867007 11.234.119.156 57240 typ host generation 0 ufrag zJX7 network-id 14 network-cost 900","sdpMLineIndex":0,"sdpMid":"0"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"candidate":"candidate:2275259511 1 udp 2121741055 fd74:6572:6d6e:7573:c:4020:81cf:2a1a 53404 typ host generation 0 ufrag zJX7 network-id 6 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"sdpMid":"0","candidate":"candidate:2445625691 1 udp 2121675519 fd74:6572:6d6e:7573:d:4020:81cf:2a1a 60196 typ host generation 0 ufrag zJX7 network-id 7 network-cost 50","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:1629018477 1 udp 2121935103 2401:d800:5ee6:c593:2dfa:61e0:2c98:f4c 50335 typ host generation 0 ufrag zJX7 network-id 15 network-cost 900"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:3725535367 1 udp 2122131711 2402:800:61d1:ee99:e182:ec59:4b96:21c4 63348 typ host generation 0 ufrag zJX7 network-id 2 network-cost 10"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:635654482 1 udp 2122063615 192.168.1.73 54610 typ host generation 0 ufrag zJX7 network-id 1 network-cost 10"},"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:1529656266 1 tcp 1518083839 192.168.1.73 60890 typ host tcptype passive generation 0 ufrag zJX7 network-id 1 network-cost 10","sdpMid":"0","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"ice":{"candidate":"candidate:2611889602 1 tcp 1518280447 30.53.17.79 60889 typ host tcptype passive generation 0 ufrag zJX7 network-id 17 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:3215536412 1 tcp 1517297407 192.0.0.6 60891 typ host tcptype passive generation 0 ufrag zJX7 network-id 10 network-cost 50"},"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"ice":{"candidate":"candidate:2021334855 1 tcp 1517887231 11.234.119.156 60892 typ host tcptype passive generation 0 ufrag zJX7 network-id 14 network-cost 900","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:2611889602 1 tcp 1517821695 30.53.17.79 60893 typ host tcptype passive generation 0 ufrag zJX7 network-id 16 network-cost 900","sdpMid":"0","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:3215536412 1 tcp 1517494015 192.0.0.6 60894 typ host tcptype passive generation 0 ufrag zJX7 network-id 5 network-cost 50"},"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"ice":{"candidate":"candidate:2611889602 1 tcp 1517428479 30.53.17.79 60895 typ host tcptype passive generation 0 ufrag zJX7 network-id 8 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:2611889602 1 tcp 1517362943 30.53.17.79 60896 typ host tcptype passive generation 0 ufrag zJX7 network-id 9 network-cost 50","sdpMid":"0","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:1878533096 1 tcp 1518220031 fdea:e111:ce6b:0:c85:bdc8:3238:f888 60897 typ host tcptype passive generation 0 ufrag zJX7 network-id 3 network-cost 10"},"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"ice":{"candidate":"candidate:4182922991 1 tcp 1517761279 fd74:6572:6d6e:7573:c:4020:81cf:2a1a 60899 typ host tcptype passive generation 0 ufrag zJX7 network-id 6 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMid":"0","candidate":"candidate:2696989215 1 tcp 1518151935 2402:800:61d1:ee99:e182:ec59:4b96:21c4 60900 typ host tcptype passive generation 0 ufrag zJX7 network-id 2 network-cost 10","sdpMLineIndex":0},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMid":"0","candidate":"candidate:534199285 1 tcp 1517955327 2401:d800:5ee6:c593:2dfa:61e0:2c98:f4c 60898 typ host tcptype passive generation 0 ufrag zJX7 network-id 15 network-cost 900","sdpMLineIndex":0},"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:4010453955 1 tcp 1517695743 fd74:6572:6d6e:7573:d:4020:81cf:2a1a 60901 typ host tcptype passive generation 0 ufrag zJX7 network-id 7 network-cost 50"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMid":"0","candidate":"candidate:1696146427 1 udp 1685855999 171.231.207.196 25306 typ srflx raddr 192.168.1.73 rport 54610 generation 0 ufrag zJX7 network-id 1 network-cost 10","sdpMLineIndex":0},"action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"action":"ice_candidate","ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:4287016364 1 udp 24911871 185.255.8.179 50305 typ relay raddr 171.231.207.196 rport 30299 generation 0 ufrag zJX7 network-id 1 network-cost 10"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMLineIndex":0,"candidate":"candidate:4213688799 1 udp 8134911 185.255.8.178 61835 typ relay raddr 171.231.207.196 rport 20254 generation 0 ufrag zJX7 network-id 1 network-cost 10","sdpMid":"0"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:3346705045 1 udp 1685659391 171.255.66.99 5993 typ srflx raddr 11.234.119.156 rport 57240 generation 0 ufrag zJX7 network-id 14 network-cost 900","sdpMLineIndex":0,"sdpMid":"0"}} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"candidate":"candidate:4287016364 1 udp 24715263 185.255.8.179 52388 typ relay raddr 171.255.66.99 rport 27478 generation 0 ufrag zJX7 network-id 14 network-cost 900","sdpMLineIndex":0,"sdpMid":"0"}} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:4213688799 1 udp 7938303 185.255.8.178 56983 typ relay raddr 171.255.66.99 rport 19798 generation 0 ufrag zJX7 network-id 14 network-cost 900","sdpMid":"0","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Received message from Portunus: {"event":"ringing","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","customData":{"avatarUrl":"https://i.pravatar.cc/300?img=12","displayName":"Nguyễn Văn Nam"},"internalCustomData":{"type":"WEBRTC","withDialog":"true","to":"customer"},"transaction":"fea6227d-5f64-4158-bbb3-64666328f93c"}
[InfobipCallKit][FreeCallVM] event=ringing phase=connecting direction=outgoing
[InfobipCallKit][Client] event → ringing
[Example] ringing

OSLOG-50DEF794-AD0D-47DA-B6B5-7766B8A52351 7 80 L 59 {t:1784080642.457859}	[INFO] Received message from Portunus: {"event":"call_response","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","isEarlyMedia":false,"description":{"type":"answer","sdp":"v=0\r\no=Infobip 1784061808 1784061809 IN IP4 81.23.249.61\r\ns=Infobip\r\nt=0 0\r\na=extmap-allow-mixed\r\na=ice-lite\r\na=fingerprint:sha-256 45:F4:34:CC:CC:8E:D4:FF:9F:09:D2:09:E4:DD:62:88:57:2A:69:65:B3:60:AC:EF:A7:F4:7E:14:82:E3:0F:3B\r\na=ice-options:trickle\r\na=msid-semantic: WMS *\r\na=group:BUNDLE 0\r\nm=audio 9 UDP/TLS/RTP/SAVPF 111 110 13\r\nc=IN IP4 81.23.249.61\r\na=rtpmap:111 opus/48000/2\r\na=rtpmap:110 telephone-event/48000\r\na=rtpmap:13 CN/8000\r\na=fmtp:111 useinbandfec=1; minptime=10\r\na=fmtp:110 0-15\r\na=setup:active\r\na=mid:0\r\na=msid:janus janus0\r\na=ptime:20\r\na=sendrecv\r\na=ice-ufrag:iFVJ\r\na=ice-pwd:fLiQxJQvouw0JbIalMNRpq\r\na=candidate:1 1 udp 2015363327 81.23.249.61 27582 typ host\r\na=candidate:2 1 udp 2015363583 81.23.249.61 28651 typ host\r\na=end-of-candidates\r\na=ice-options:trickle\r\na=ssrc:81049
Logging Error: Failed to receive 1 log messages. Please review standard output for possible log message content.
[INFO] peerConnection new signaling state: stable
[INFO] audio peerConnection new connection state: checking
[INFO] Received message from Portunus: {"event":"joined_video_call"}
[INFO] Received message from Portunus: {"event":"dialog_established","id":"4eaac0db-9b7d-4e6d-900c-e800abc977a5","participants":[{"streams":{},"endpoint":{"type":"WEBRTC","identity":"driver","displayName":"Nguyễn Văn Nam"},"media":{"audio":{"muted":false,"deaf":false,"userMuted":false},"video":{"screenShare":false,"camera":false,"blind":false}},"state":"JOINED","disconnected":false,"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","role":null},{"streams":{},"endpoint":{"type":"WEBRTC","identity":"customer"},"media":{"audio":{"muted":false,"deaf":false,"userMuted":false},"video":{"screenShare":false,"camera":false,"blind":false}},"state":"JOINED","disconnected":false,"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","role":null}]}
[INFO] Received message from Portunus: {"event":"joined_video_conference"}
[INFO] Received message from Portunus: {"event":"setup_data_channel","description":{"type":"offer","sdp":"v=0\r\no=- 1784080642693171 1 IN IP4 81.23.249.62\r\ns=Janus TextRoom plugin\r\nt=0 0\r\na=group:BUNDLE 0\r\na=ice-options:trickle\r\na=fingerprint:sha-256 45:F4:34:CC:CC:8E:D4:FF:9F:09:D2:09:E4:DD:62:88:57:2A:69:65:B3:60:AC:EF:A7:F4:7E:14:82:E3:0F:3B\r\na=extmap-allow-mixed\r\na=msid-semantic: WMS *\r\na=ice-lite\r\nm=application 9 UDP/DTLS/SCTP webrtc-datachannel\r\nc=IN IP4 81.23.249.62\r\na=sendrecv\r\na=mid:0\r\na=sctp-port:5000\r\na=ice-ufrag:Lwvs\r\na=ice-pwd:SamsiUhj4S+KEqs4XMP2Wk\r\na=ice-options:trickle\r\na=setup:actpass\r\na=candidate:1 1 udp 2015363327 81.23.249.62 28230 typ host\r\na=candidate:2 1 udp 2015363583 81.23.249.62 37704 typ host\r\na=end-of-candidates\r\n"},"id":"4eaac0db-9b7d-4e6d-900c-e800abc977a5@1456863.infobip.com"}
[INFO] audio peerConnection new connection state: connected
[INFO] Sending {"action":"ice_candidate_pair_selected","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","selectedCandidatePair":{"remote":{"ip":"81.23.249.61","type":"host","protocol":"udp","port":27582},"local":{"ip":"171.231.207.196","type":"prflx","protocol":"udp","port":11653}}} to Infobip Gateway.
[InfobipCallKit][FreeCallVM] event=established phase=ringing direction=outgoing
[InfobipCallKit][Client] event → established
[Example] established
[InfobipCallKit][FreeCallVM] event=audioRouteChanged(InfobipCallKit.AudioRouteOption(id: "Built-In Microphone#0", name: "iPhone", kind: InfobipCallKit.AudioRouteOption.Kind.builtin, isActive: true)) phase=established direction=outgoing
[InfobipCallKit][Client] event → audioRouteChanged(name: "iPhone")
[Example] audio route: iPhone
[INFO] Sending {"reason":"Normal call clearing","action":"hangup","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
           SessionCore.mm:546   Failed to set properties, error: '!pri'
[WARNING] Failed to set normal Audio mode after call: The operation couldn’t be completed. (OSStatus error 561017449.)
[INFO] audio peerConnection new connection state: closed
[INFO] peerConnection new signaling state: closed
[InfobipCallKit][ActiveCall] onHangup code=10000 name=NORMAL_HANGUP
[InfobipCallKit][FreeCallVM] event=hangup(InfobipCallKit.CallEndReason(code: 10000, name: "NORMAL_HANGUP", message: "The call ended due to a hangup initiated by the caller, callee, or API.", isError: false)) phase=established direction=outgoing
[InfobipCallKit][FreeCallVM] finish wasEstablished=true local=true route=backToHome delay=0.0
[InfobipCallKit][CallKit] reportCallEnded uuid=72A7BD33-C874-4AAC-B874-E2C173C5061E reason=2
[InfobipCallKit][Client] event → ended(InfobipCallKit.CallEndReason(code: 10000, name: "NORMAL_HANGUP", message: "The call ended due to a hangup initiated by the caller, callee, or API.", isError: false))
[Example] call ended: NORMAL_HANGUP (code 10000, isError: false) — The call ended due to a hangup initiated by the caller, callee, or API.
[InfobipCallKit][FreeCallVM] triggering route backToHome
[INFO] Successfully submitted 10 logs
tcp_input [C4.1.1.1:3] flags=[R] seq=98426889, ack=0, win=0 state=LAST_ACK rcv_nxt=98426889, snd_una=2203007579[InfobipCallKit][Center] InfobipCallCenter initialized (pushConfigId=1ce41cec-c13a-41b2-80dc-de54cf62d6bf)
[InfobipCallKit][Client] activateCallService()
[InfobipCallKit][CallService] CallKit activated
[InfobipCallKit][Client] enablePushNotifications(credentials:)
[InfobipCallKit][CallService] host provided VoIP push credentials
[InfobipCallKit][Client] registerSubscriber(identity: driver, hasImage: true)
[InfobipCallKit][CallService] registered subscriber driver displayName=Nguyễn Văn Nam hasImage=true
[InfobipCallKit][Client] registerForIncomingCalls()
[InfobipCallKit][CallService] enablePushNotification status=success message=Successfully registered for notifications with device: E2FD063DBFC1A1856A2E585C8BB5DBC2B79C9C03A2ACE9A46CEFCC72F268504D
tcp_input [C1.1.1.1:3] flags=[R] seq=1979754986, ack=0, win=0 state=LAST_ACK rcv_nxt=1979754986, snd_una=3063182271
tcp_input [C2.1.1.1:3] flags=[R] seq=383735509, ack=0, win=0 state=LAST_ACK rcv_nxt=383735509, snd_una=1295622146
[InfobipCallKit][Client] startOutgoingCall(destinationIdentity: customer)
[InfobipCallKit][CallService] makeCall → customer callee=Trần Thị Hoa customData keys=["avatarUrl", "displayName"]
[InfobipCallKit][Client] event → started(InfobipCallKit.CallSession(id: "72a7bd33-c874-4aac-b874-e2c173c5061e", direction: InfobipCallKit.CallSession.Direction.outgoing, status: InfobipCallKit.CallSession.Status.connecting, counterpartIdentity: "customer", counterpartDisplayName: "Trần Thị Hoa", counterpartAvatarURL: Optional(https://i.pravatar.cc/300?u=gsmcall-customer), isMuted: false, isSpeakerOn: false, durationSeconds: 0, networkQuality: nil, endReason: nil))
[Example] call started → Trần Thị Hoa (outgoing)
[InfobipCallKit][FreeCallVM] event=audioRouteChanged(InfobipCallKit.AudioRouteOption(id: "Built-In Microphone#0", name: "iPhone", kind: InfobipCallKit.AudioRouteOption.Kind.builtin, isActive: true)) phase=connecting direction=outgoing
[InfobipCallKit][Client] event → audioRouteChanged(name: "iPhone")
[Example] audio route: iPhone
[INFO] Socket viability changed, viable: True
[INFO] Connected to Portunus.
[INFO] Received message from Portunus: {"event":"registered","identity":"driver","iceServers":[{"urls":"stun:stun.infobip.com:443"},{"urls":"turns:munm3.turn.infobip.com:443?transport=tcp","credential":"2YvBNpA5qToWeBlHKi6XNNQ9iTA=","username":"1784109367:driver"},{"urls":"turn:185.255.8.179:443?transport=tcp","credential":"2YvBNpA5qToWeBlHKi6XNNQ9iTA=","username":"1784109367:driver"}],"apiUrl":"pd11gl.api-id.infobip.com","logLevel":"WARNING","instanceHash":"0af259c2afda2c947db52b7f69f949c23afdc725539e8335f751ede4910658c0","transaction":"88cfc526-f4fc-4223-877f-5eb3927c90da"}
[INFO] Registered as driver successfully.
[INFO] peerConnection should negotiate
[INFO] peerConnection new signaling state: haveLocalOffer
[INFO] Sending {"callsConfigurationId":"WEBRTC","platform":{},"media":{"video":{"camera":false},"audio":{"muted":false}},"internalCustomData":{"type":"WEBRTC","withDialog":"true","to":"customer"},"videoMode":"PRESENTATION","destination":"customer","action":"application_call","description":{"type":"offer","sdp":"v=0\r\no=- 3102423823683446356 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=group:BUNDLE 0\r\na=extmap-allow-mixed\r\na=msid-semantic: WMS\r\nm=audio 9 UDP\/TLS\/RTP\/SAVPF 111 63 9 0 8 13 110 126\r\nc=IN IP4 0.0.0.0\r\na=rtcp:9 IN IP4 0.0.0.0\r\na=ice-ufrag:zJX7\r\na=ice-pwd:W+r9UvBcEMo57FYlNO3FuyvD\r\na=ice-options:trickle renomination\r\na=fingerprint:sha-256 CA:F4:22:E3:90:5C:4B:B6:57:23:FA:4A:54:62:12:D8:77:E1:28:77:B5:47:42:7D:51:C4:C9:8D:46:1A:04:18\r\na=setup:actpass\r\na=mid:0\r\na=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level\r\na=extmap:2 http:\/\/www.webrtc.org\/experiments\/rtp-hdrext\/abs-send-time\r\na=extmap:3 http:\/\/www.ietf.org\/id\/draft-holmer-rmcat-transport-wide-cc-extensions
[INFO] peerConnection new gathering state: gathering
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:3244741508 1 udp 2121277183 192.0.0.6 58644 typ host generation 0 ufrag zJX7 network-id 10 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"}} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"candidate":"candidate:3848382298 1 udp 2121801471 30.53.17.79 50924 typ host generation 0 ufrag zJX7 network-id 16 network-cost 900","sdpMLineIndex":0,"sdpMid":"0"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMid":"0","candidate":"candidate:3848382298 1 udp 2122260223 30.53.17.79 57988 typ host generation 0 ufrag zJX7 network-id 17 network-cost 50","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMid":"0","candidate":"candidate:3244741508 1 udp 2121473791 192.0.0.6 64389 typ host generation 0 ufrag zJX7 network-id 5 network-cost 50","sdpMLineIndex":0},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:3848382298 1 udp 2121408255 30.53.17.79 61699 typ host generation 0 ufrag zJX7 network-id 8 network-cost 50"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"sdpMid":"0","candidate":"candidate:288866672 1 udp 2122199807 fdea:e111:ce6b:0:c85:bdc8:3238:f888 50996 typ host generation 0 ufrag zJX7 network-id 3 network-cost 10","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"ice":{"candidate":"candidate:3848382298 1 udp 2121342719 30.53.17.79 62242 typ host generation 0 ufrag zJX7 network-id 9 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"candidate":"candidate:112524767 1 udp 2121867007 11.234.119.156 57240 typ host generation 0 ufrag zJX7 network-id 14 network-cost 900","sdpMLineIndex":0,"sdpMid":"0"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"candidate":"candidate:2275259511 1 udp 2121741055 fd74:6572:6d6e:7573:c:4020:81cf:2a1a 53404 typ host generation 0 ufrag zJX7 network-id 6 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"sdpMid":"0","candidate":"candidate:2445625691 1 udp 2121675519 fd74:6572:6d6e:7573:d:4020:81cf:2a1a 60196 typ host generation 0 ufrag zJX7 network-id 7 network-cost 50","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:1629018477 1 udp 2121935103 2401:d800:5ee6:c593:2dfa:61e0:2c98:f4c 50335 typ host generation 0 ufrag zJX7 network-id 15 network-cost 900"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:3725535367 1 udp 2122131711 2402:800:61d1:ee99:e182:ec59:4b96:21c4 63348 typ host generation 0 ufrag zJX7 network-id 2 network-cost 10"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:635654482 1 udp 2122063615 192.168.1.73 54610 typ host generation 0 ufrag zJX7 network-id 1 network-cost 10"},"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:1529656266 1 tcp 1518083839 192.168.1.73 60890 typ host tcptype passive generation 0 ufrag zJX7 network-id 1 network-cost 10","sdpMid":"0","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"ice":{"candidate":"candidate:2611889602 1 tcp 1518280447 30.53.17.79 60889 typ host tcptype passive generation 0 ufrag zJX7 network-id 17 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:3215536412 1 tcp 1517297407 192.0.0.6 60891 typ host tcptype passive generation 0 ufrag zJX7 network-id 10 network-cost 50"},"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"ice":{"candidate":"candidate:2021334855 1 tcp 1517887231 11.234.119.156 60892 typ host tcptype passive generation 0 ufrag zJX7 network-id 14 network-cost 900","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:2611889602 1 tcp 1517821695 30.53.17.79 60893 typ host tcptype passive generation 0 ufrag zJX7 network-id 16 network-cost 900","sdpMid":"0","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:3215536412 1 tcp 1517494015 192.0.0.6 60894 typ host tcptype passive generation 0 ufrag zJX7 network-id 5 network-cost 50"},"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"ice":{"candidate":"candidate:2611889602 1 tcp 1517428479 30.53.17.79 60895 typ host tcptype passive generation 0 ufrag zJX7 network-id 8 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:2611889602 1 tcp 1517362943 30.53.17.79 60896 typ host tcptype passive generation 0 ufrag zJX7 network-id 9 network-cost 50","sdpMid":"0","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:1878533096 1 tcp 1518220031 fdea:e111:ce6b:0:c85:bdc8:3238:f888 60897 typ host tcptype passive generation 0 ufrag zJX7 network-id 3 network-cost 10"},"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"ice":{"candidate":"candidate:4182922991 1 tcp 1517761279 fd74:6572:6d6e:7573:c:4020:81cf:2a1a 60899 typ host tcptype passive generation 0 ufrag zJX7 network-id 6 network-cost 50","sdpMLineIndex":0,"sdpMid":"0"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMid":"0","candidate":"candidate:2696989215 1 tcp 1518151935 2402:800:61d1:ee99:e182:ec59:4b96:21c4 60900 typ host tcptype passive generation 0 ufrag zJX7 network-id 2 network-cost 10","sdpMLineIndex":0},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMid":"0","candidate":"candidate:534199285 1 tcp 1517955327 2401:d800:5ee6:c593:2dfa:61e0:2c98:f4c 60898 typ host tcptype passive generation 0 ufrag zJX7 network-id 15 network-cost 900","sdpMLineIndex":0},"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:4010453955 1 tcp 1517695743 fd74:6572:6d6e:7573:d:4020:81cf:2a1a 60901 typ host tcptype passive generation 0 ufrag zJX7 network-id 7 network-cost 50"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMid":"0","candidate":"candidate:1696146427 1 udp 1685855999 171.231.207.196 25306 typ srflx raddr 192.168.1.73 rport 54610 generation 0 ufrag zJX7 network-id 1 network-cost 10","sdpMLineIndex":0},"action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"action":"ice_candidate","ice":{"sdpMLineIndex":0,"sdpMid":"0","candidate":"candidate:4287016364 1 udp 24911871 185.255.8.179 50305 typ relay raddr 171.231.207.196 rport 30299 generation 0 ufrag zJX7 network-id 1 network-cost 10"},"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"sdpMLineIndex":0,"candidate":"candidate:4213688799 1 udp 8134911 185.255.8.178 61835 typ relay raddr 171.231.207.196 rport 20254 generation 0 ufrag zJX7 network-id 1 network-cost 10","sdpMid":"0"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:3346705045 1 udp 1685659391 171.255.66.99 5993 typ srflx raddr 11.234.119.156 rport 57240 generation 0 ufrag zJX7 network-id 14 network-cost 900","sdpMLineIndex":0,"sdpMid":"0"}} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"action":"ice_candidate","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","ice":{"candidate":"candidate:4287016364 1 udp 24715263 185.255.8.179 52388 typ relay raddr 171.255.66.99 rport 27478 generation 0 ufrag zJX7 network-id 14 network-cost 900","sdpMLineIndex":0,"sdpMid":"0"}} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","action":"ice_candidate","ice":{"candidate":"candidate:4213688799 1 udp 7938303 185.255.8.178 56983 typ relay raddr 171.255.66.99 rport 19798 generation 0 ufrag zJX7 network-id 14 network-cost 900","sdpMid":"0","sdpMLineIndex":0}} to Infobip Gateway.
[INFO] Received message from Portunus: {"event":"ringing","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","customData":{"avatarUrl":"https://i.pravatar.cc/300?img=12","displayName":"Nguyễn Văn Nam"},"internalCustomData":{"type":"WEBRTC","withDialog":"true","to":"customer"},"transaction":"fea6227d-5f64-4158-bbb3-64666328f93c"}
[InfobipCallKit][FreeCallVM] event=ringing phase=connecting direction=outgoing
[InfobipCallKit][Client] event → ringing
[Example] ringing

OSLOG-50DEF794-AD0D-47DA-B6B5-7766B8A52351 7 80 L 59 {t:1784080642.457859}	[INFO] Received message from Portunus: {"event":"call_response","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","isEarlyMedia":false,"description":{"type":"answer","sdp":"v=0\r\no=Infobip 1784061808 1784061809 IN IP4 81.23.249.61\r\ns=Infobip\r\nt=0 0\r\na=extmap-allow-mixed\r\na=ice-lite\r\na=fingerprint:sha-256 45:F4:34:CC:CC:8E:D4:FF:9F:09:D2:09:E4:DD:62:88:57:2A:69:65:B3:60:AC:EF:A7:F4:7E:14:82:E3:0F:3B\r\na=ice-options:trickle\r\na=msid-semantic: WMS *\r\na=group:BUNDLE 0\r\nm=audio 9 UDP/TLS/RTP/SAVPF 111 110 13\r\nc=IN IP4 81.23.249.61\r\na=rtpmap:111 opus/48000/2\r\na=rtpmap:110 telephone-event/48000\r\na=rtpmap:13 CN/8000\r\na=fmtp:111 useinbandfec=1; minptime=10\r\na=fmtp:110 0-15\r\na=setup:active\r\na=mid:0\r\na=msid:janus janus0\r\na=ptime:20\r\na=sendrecv\r\na=ice-ufrag:iFVJ\r\na=ice-pwd:fLiQxJQvouw0JbIalMNRpq\r\na=candidate:1 1 udp 2015363327 81.23.249.61 27582 typ host\r\na=candidate:2 1 udp 2015363583 81.23.249.61 28651 typ host\r\na=end-of-candidates\r\na=ice-options:trickle\r\na=ssrc:81049
Logging Error: Failed to receive 1 log messages. Please review standard output for possible log message content.
[INFO] peerConnection new signaling state: stable
[INFO] audio peerConnection new connection state: checking
[INFO] Received message from Portunus: {"event":"joined_video_call"}
[INFO] Received message from Portunus: {"event":"dialog_established","id":"4eaac0db-9b7d-4e6d-900c-e800abc977a5","participants":[{"streams":{},"endpoint":{"type":"WEBRTC","identity":"driver","displayName":"Nguyễn Văn Nam"},"media":{"audio":{"muted":false,"deaf":false,"userMuted":false},"video":{"screenShare":false,"camera":false,"blind":false}},"state":"JOINED","disconnected":false,"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","role":null},{"streams":{},"endpoint":{"type":"WEBRTC","identity":"customer"},"media":{"audio":{"muted":false,"deaf":false,"userMuted":false},"video":{"screenShare":false,"camera":false,"blind":false}},"state":"JOINED","disconnected":false,"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","role":null}]}
[INFO] Received message from Portunus: {"event":"joined_video_conference"}
[INFO] Received message from Portunus: {"event":"setup_data_channel","description":{"type":"offer","sdp":"v=0\r\no=- 1784080642693171 1 IN IP4 81.23.249.62\r\ns=Janus TextRoom plugin\r\nt=0 0\r\na=group:BUNDLE 0\r\na=ice-options:trickle\r\na=fingerprint:sha-256 45:F4:34:CC:CC:8E:D4:FF:9F:09:D2:09:E4:DD:62:88:57:2A:69:65:B3:60:AC:EF:A7:F4:7E:14:82:E3:0F:3B\r\na=extmap-allow-mixed\r\na=msid-semantic: WMS *\r\na=ice-lite\r\nm=application 9 UDP/DTLS/SCTP webrtc-datachannel\r\nc=IN IP4 81.23.249.62\r\na=sendrecv\r\na=mid:0\r\na=sctp-port:5000\r\na=ice-ufrag:Lwvs\r\na=ice-pwd:SamsiUhj4S+KEqs4XMP2Wk\r\na=ice-options:trickle\r\na=setup:actpass\r\na=candidate:1 1 udp 2015363327 81.23.249.62 28230 typ host\r\na=candidate:2 1 udp 2015363583 81.23.249.62 37704 typ host\r\na=end-of-candidates\r\n"},"id":"4eaac0db-9b7d-4e6d-900c-e800abc977a5@1456863.infobip.com"}
[INFO] audio peerConnection new connection state: connected
[INFO] Sending {"action":"ice_candidate_pair_selected","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","selectedCandidatePair":{"remote":{"ip":"81.23.249.61","type":"host","protocol":"udp","port":27582},"local":{"ip":"171.231.207.196","type":"prflx","protocol":"udp","port":11653}}} to Infobip Gateway.
[InfobipCallKit][FreeCallVM] event=established phase=ringing direction=outgoing
[InfobipCallKit][Client] event → established
[Example] established
[InfobipCallKit][FreeCallVM] event=audioRouteChanged(InfobipCallKit.AudioRouteOption(id: "Built-In Microphone#0", name: "iPhone", kind: InfobipCallKit.AudioRouteOption.Kind.builtin, isActive: true)) phase=established direction=outgoing
[InfobipCallKit][Client] event → audioRouteChanged(name: "iPhone")
[Example] audio route: iPhone
[INFO] Sending {"reason":"Normal call clearing","action":"hangup","callId":"72a7bd33-c874-4aac-b874-e2c173c5061e"} to Infobip Gateway.
           SessionCore.mm:546   Failed to set properties, error: '!pri'
[WARNING] Failed to set normal Audio mode after call: The operation couldn’t be completed. (OSStatus error 561017449.)
[INFO] audio peerConnection new connection state: closed
[INFO] peerConnection new signaling state: closed
[InfobipCallKit][ActiveCall] onHangup code=10000 name=NORMAL_HANGUP
[InfobipCallKit][FreeCallVM] event=hangup(InfobipCallKit.CallEndReason(code: 10000, name: "NORMAL_HANGUP", message: "The call ended due to a hangup initiated by the caller, callee, or API.", isError: false)) phase=established direction=outgoing
[InfobipCallKit][FreeCallVM] finish wasEstablished=true local=true route=backToHome delay=0.0
[InfobipCallKit][CallKit] reportCallEnded uuid=72A7BD33-C874-4AAC-B874-E2C173C5061E reason=2
[InfobipCallKit][Client] event → ended(InfobipCallKit.CallEndReason(code: 10000, name: "NORMAL_HANGUP", message: "The call ended due to a hangup initiated by the caller, callee, or API.", isError: false))
[Example] call ended: NORMAL_HANGUP (code 10000, isError: false) — The call ended due to a hangup initiated by the caller, callee, or API.
[InfobipCallKit][FreeCallVM] triggering route backToHome
[INFO] Successfully submitted 10 logs
tcp_input [C4.1.1.1:3] flags=[R] seq=98426889, ack=0, win=0 state=LAST_ACK rcv_nxt=98426889, snd_una=2203007579
==================================================
Callee Log

[InfobipCallKit][Center] InfobipCallCenter initialized (pushConfigId=1ce41cec-c13a-41b2-80dc-de54cf62d6bf)
[InfobipCallKit][Client] activateCallService()
[InfobipCallKit][CallService] CallKit activated
[InfobipCallKit][Client] enablePushNotifications(credentials:)
[InfobipCallKit][CallService] host provided VoIP push credentials
[InfobipCallKit][Client] registerSubscriber(identity: customer, hasImage: true)
[InfobipCallKit][CallService] registered subscriber customer displayName=Trần Thị Hoa hasImage=true
[InfobipCallKit][Client] registerForIncomingCalls()
[InfobipCallKit][CallService] enablePushNotification status=success message=Successfully registered for notifications with device: 252584C9A2454F94CC7C9B1D4A0290416823BBBEFA9793C00D2C62ACB3326F40
tcp_input [C1.1.1.1:3] flags=[R] seq=3349677833, ack=0, win=0 state=LAST_ACK rcv_nxt=3349677833, snd_una=2580509008
tcp_input [C2.1.1.1:3] flags=[R] seq=888903184, ack=0, win=0 state=LAST_ACK rcv_nxt=888903184, snd_una=1342585996
[InfobipCallKit][Client] handleIncomingPush(payload:)
[InfobipCallKit][CallService] didReceiveIncomingPush type=PKPushTypeVoIP payload=[AnyHashable("source"): driver, AnyHashable("callsConfigurationId"): WEBRTC, AnyHashable("applicationId"): WEBRTC, AnyHashable("callType"): INBOUND_APPLICATION, AnyHashable("internalCustomData"): {"type":"WEBRTC","withDialog":"true","to":"customer"}, AnyHashable("aps"): {
}, AnyHashable("customData"): {"avatarUrl":"https://i.pravatar.cc/300?img=12","displayName":"Nguyễn Văn Nam"}, AnyHashable("correlationId"): 4a939278-9ade-4da0-a913-b5a28e2e7275, AnyHashable("InfobipRTCCall"): 1, AnyHashable("callId"): 4a939278-9ade-4da0-a913-b5a28e2e7275, AnyHashable("token"): eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhY2MiOiIzOERFM0EwNDJGMDlENjFFQjA2RDZCRTNGRkYyNTYwQyIsImRzdCI6bnVsbCwiaWRlbnRpdHkiOiJjdXN0b21lciIsImlzcyI6IkluZm9iaXAiLCJuYW1lIjpudWxsLCJsb2NhdGlvbiI6ImlkIiwiZXhwIjoxNzg0MTA5NDM2LCJ1cmwiOiJwZDExZ2wuYXBpLWlkLmluZm9iaXAuY29tIn0.S5tAbz-TOeySQ39VlbmqCFUdseZFAsC66f8AleG0LMM, AnyHashable("displayName"): Nguyễn Văn Nam]
[InfobipCallKit][CallKit] reportIncomingCall uuid=4A939278-9ADE-4DA0-A913-B5A28E2E7275 name=CallKit Example
[InfobipCallKit][CallService] onIncomingWebrtcCall from driver
[InfobipCallKit][Client] event → started(InfobipCallKit.CallSession(id: "4a939278-9ade-4da0-a913-b5a28e2e7275", direction: InfobipCallKit.CallSession.Direction.incoming, status: InfobipCallKit.CallSession.Status.ringing, counterpartIdentity: "driver", counterpartDisplayName: "Nguyễn Văn Nam", counterpartAvatarURL: Optional(https://i.pravatar.cc/300?img=12), isMuted: false, isSpeakerOn: false, durationSeconds: 0, networkQuality: nil, endReason: nil))
[Example] call started → Nguyễn Văn Nam (incoming)
[INFO] Socket viability changed, viable: True
[INFO] Successfully submitted 1 logs
[INFO] Successfully submitted 1 logs
[INFO] Connected to Portunus.
[INFO] Received message from Portunus: {"event":"registered","identity":"customer","iceServers":[{"urls":"stun:stun.infobip.net:443"},{"urls":"turns:munm3.turn.infobip.com:443?transport=tcp","credential":"O8ysW0nUjDGDNx5lcQQqoXne9/c=","username":"1784109436:customer"},{"urls":"turn:185.255.8.179:443?transport=tcp","credential":"O8ysW0nUjDGDNx5lcQQqoXne9/c=","username":"1784109436:customer"}],"apiUrl":"pd11gl.api-id.infobip.com","logLevel":"WARNING","instanceHash":"0af259c2afda2c947db52b7f69f949c23afdc725539e8335f751ede4910658c0","transaction":"94f945a2-ef69-4f57-b1aa-3839d4b855c9"}
[INFO] Registered as customer successfully.
[INFO] Received message from Portunus: {"event":"application_call","callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","correlationId":"4a939278-9ade-4da0-a913-b5a28e2e7275","caller":{"displayName":"Nguyễn Văn Nam","identity":"driver"},"description":{"type":"offer","sdp":"v=0\r\no=Infobip 1784053104 1784053105 IN IP4 81.23.249.62\r\ns=Infobip\r\nt=0 0\r\na=extmap-allow-mixed\r\na=ice-lite\r\na=fingerprint:sha-256 45:F4:34:CC:CC:8E:D4:FF:9F:09:D2:09:E4:DD:62:88:57:2A:69:65:B3:60:AC:EF:A7:F4:7E:14:82:E3:0F:3B\r\na=ice-options:trickle\r\na=msid-semantic: WMS *\r\na=group:BUNDLE 0\r\nm=audio 9 UDP/TLS/RTP/SAVPF 102 101 13\r\nc=IN IP4 81.23.249.62\r\na=rtpmap:102 opus/48000/2\r\na=rtpmap:101 telephone-event/48000\r\na=rtpmap:13 CN/48000\r\na=fmtp:102 useinbandfec=1; maxaveragebitrate=30000; maxplaybackrate=48000; ptime=20; minptime=10; maxptime=40\r\na=fmtp:101 0-15\r\na=setup:actpass\r\na=mid:0\r\na=msid:janus janus0\r\na=ptime:20\r\na=sendrecv\r\na=ice-ufrag:GHil\r\na=ice-pwd:VdbWm+bxkd1bjf+swd/qaa\r\na=candidat
[INFO] Sending {"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","transaction":"a9273581-7ff4-4d80-b0c9-9f460f1e480a","action":"event_ack"} to Infobip Gateway.
[INFO] peerConnection new signaling state: haveRemoteOffer
[INFO] peerConnection new signaling state: stable
[INFO] Sending {"media":{"video":{"camera":false},"audio":{"muted":false}},"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","autoReconnect":false,"action":"application_call_accept","description":{"type":"answer","sdp":"v=0\r\no=- 2210956480748811069 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=group:BUNDLE 0\r\na=extmap-allow-mixed\r\na=msid-semantic: WMS INFOBIP\r\nm=audio 9 UDP\/TLS\/RTP\/SAVPF 102 101\r\nc=IN IP4 0.0.0.0\r\na=rtcp:9 IN IP4 0.0.0.0\r\na=ice-ufrag:SITj\r\na=ice-pwd:bh01o29D0IbrCWZngDQ51Bya\r\na=ice-options:trickle renomination\r\na=fingerprint:sha-256 29:AE:13:06:B9:13:35:BA:6B:5F:25:40:AA:20:07:1D:75:61:92:0A:B5:3B:DC:08:D5:69:1E:DF:22:A4:BA:1A\r\na=setup:active\r\na=mid:0\r\na=sendrecv\r\na=msid:INFOBIP 02bf43db-cde2-4325-a436-120b89c73363\r\na=rtcp-mux\r\na=rtpmap:102 opus\/48000\/2\r\na=fmtp:102 minptime=10;useinbandfec=1\r\na=rtpmap:101 telephone-event\/48000\r\na=ssrc:237813139 cname:fW5vMM8p2CRalbxF\r\n"}} to Infobip Gateway.
[INFO] audio peerConnection new connection state: checking
[INFO] peerConnection new gathering state: gathering
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"ice":{"sdpMid":"0","sdpMLineIndex":0,"candidate":"candidate:2395035148 1 udp 2121539327 25.81.99.253 57331 typ host generation 0 ufrag SITj network-id 8 network-cost 50"},"action":"ice_candidate","callId":"4a939278-9ade-4da0-a913-b5a28e2e7275"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMid":"0","sdpMLineIndex":0,"candidate":"candidate:2395035148 1 udp 2121867007 25.81.99.253 50293 typ host generation 0 ufrag SITj network-id 13 network-cost 900"},"action":"ice_candidate","callId":"4a939278-9ade-4da0-a913-b5a28e2e7275"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMid":"0","sdpMLineIndex":0,"candidate":"candidate:1219234230 1 udp 2122129151 192.168.1.150 50022 typ host generation 0 ufrag SITj network-id 1 network-cost 10"},"action":"ice_candidate","callId":"4a939278-9ade-4da0-a913-b5a28e2e7275"} to Infobip Gateway.
[INFO] Sending {"ice":{"candidate":"candidate:2395035148 1 udp 2121735935 25.81.99.253 49291 typ host generation 0 ufrag SITj network-id 5 network-cost 50","sdpMid":"0","sdpMLineIndex":0},"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMid":"0","sdpMLineIndex":0,"candidate":"candidate:2395035148 1 udp 2121670399 25.81.99.253 52207 typ host generation 0 ufrag SITj network-id 6 network-cost 50"},"action":"ice_candidate","callId":"4a939278-9ade-4da0-a913-b5a28e2e7275"} to Infobip Gateway.
[INFO] Sending {"ice":{"candidate":"candidate:2395035148 1 udp 2121604863 25.81.99.253 55080 typ host generation 0 ufrag SITj network-id 7 network-cost 50","sdpMid":"0","sdpMLineIndex":0},"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"action":"ice_candidate","callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","ice":{"sdpMid":"0","sdpMLineIndex":0,"candidate":"candidate:2012120209 1 udp 2121932543 10.125.27.199 49292 typ host generation 0 ufrag SITj network-id 11 network-cost 900"}} to Infobip Gateway.
[INFO] Sending {"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","ice":{"sdpMid":"0","sdpMLineIndex":0,"candidate":"candidate:3137610284 1 udp 2122265343 fdea:e111:ce6b:0:873:4009:833d:50a7 52164 typ host generation 0 ufrag SITj network-id 3 network-cost 10"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","ice":{"sdpMid":"0","sdpMLineIndex":0,"candidate":"candidate:468887819 1 udp 2122197247 2402:800:61d1:ee99:4c36:a5e0:8517:288c 58511 typ host generation 0 ufrag SITj network-id 2 network-cost 10"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"action":"ice_candidate","callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","ice":{"sdpMid":"0","sdpMLineIndex":0,"candidate":"candidate:3089275986 1 udp 2122000639 2402:9d80:289:ace8:7072:b3be:7a01:21a5 49822 typ host generation 0 ufrag SITj network-id 12 network-cost 900"}} to Infobip Gateway.
[INFO] Sending {"action":"ice_candidate","callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","ice":{"sdpMid":"0","sdpMLineIndex":0,"candidate":"candidate:1235038048 1 udp 2121806591 fdba:2425:21a2::1 62200 typ host generation 0 ufrag SITj network-id 14 network-cost 50"}} to Infobip Gateway.
[InfobipCallKit][Client] event → audioRouteChanged(name: "iPhone")
[Example] audio route: iPhone
[InfobipCallKit][FreeCallVM] event=audioRouteChanged(InfobipCallKit.AudioRouteOption(id: "Built-In Microphone#0", name: "iPhone", kind: InfobipCallKit.AudioRouteOption.Kind.builtin, isActive: true)) phase=connecting direction=incoming
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"ice":{"sdpMid":"0","candidate":"candidate:912517934 1 tcp 1518149375 192.168.1.150 50419 typ host tcptype passive generation 0 ufrag SITj network-id 1 network-cost 10","sdpMLineIndex":0},"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"ice":{"sdpMid":"0","candidate":"candidate:4027495572 1 tcp 1517559551 25.81.99.253 50420 typ host tcptype passive generation 0 ufrag SITj network-id 8 network-cost 50","sdpMLineIndex":0},"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"ice":{"sdpMid":"0","candidate":"candidate:4027495572 1 tcp 1517887231 25.81.99.253 50422 typ host tcptype passive generation 0 ufrag SITj network-id 13 network-cost 900","sdpMLineIndex":0},"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","ice":{"sdpMid":"0","sdpMLineIndex":0,"candidate":"candidate:153183753 1 tcp 1517952767 10.125.27.199 50421 typ host tcptype passive generation 0 ufrag SITj network-id 11 network-cost 900"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"ice":{"sdpMid":"0","candidate":"candidate:4027495572 1 tcp 1517756159 25.81.99.253 50423 typ host tcptype passive generation 0 ufrag SITj network-id 5 network-cost 50","sdpMLineIndex":0},"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","ice":{"sdpMLineIndex":0,"candidate":"candidate:4027495572 1 tcp 1517690623 25.81.99.253 50424 typ host tcptype passive generation 0 ufrag SITj network-id 6 network-cost 50","sdpMid":"0"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","ice":{"sdpMLineIndex":0,"candidate":"candidate:4027495572 1 tcp 1517625087 25.81.99.253 50425 typ host tcptype passive generation 0 ufrag SITj network-id 7 network-cost 50","sdpMid":"0"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","ice":{"sdpMLineIndex":0,"candidate":"candidate:3318464692 1 tcp 1518285567 fdea:e111:ce6b:0:873:4009:833d:50a7 50426 typ host tcptype passive generation 0 ufrag SITj network-id 3 network-cost 10","sdpMid":"0"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","ice":{"sdpMLineIndex":0,"candidate":"candidate:1698515859 1 tcp 1518217471 2402:800:61d1:ee99:4c36:a5e0:8517:288c 50427 typ host tcptype passive generation 0 ufrag SITj network-id 2 network-cost 10","sdpMid":"0"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] audio peerConnection received ICE candidate
[INFO] Sending {"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","ice":{"sdpMLineIndex":0,"candidate":"candidate:3337453258 1 tcp 1518020863 2402:9d80:289:ace8:7072:b3be:7a01:21a5 50428 typ host tcptype passive generation 0 ufrag SITj network-id 12 network-cost 900","sdpMid":"0"},"action":"ice_candidate"} to Infobip Gateway.
[INFO] Sending {"ice":{"sdpMid":"0","candidate":"candidate:928173560 1 tcp 1517826815 fdba:2425:21a2::1 50429 typ host tcptype passive generation 0 ufrag SITj network-id 14 network-cost 50","sdpMLineIndex":0},"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","action":"ice_candidate"} to Infobip Gateway.
[INFO] Received message from Portunus: {"event":"call_accepted","callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","transaction":"c3a456de-e8b5-432d-be10-ae93c33bc944"}
[INFO] Received message from Portunus: {"event":"joined_video_call"}
[INFO] Received message from Portunus: {"event":"dialog_established","id":"4eaac0db-9b7d-4e6d-900c-e800abc977a5","participants":[{"streams":{},"endpoint":{"type":"WEBRTC","identity":"driver","displayName":"Nguyễn Văn Nam"},"media":{"audio":{"muted":false,"deaf":false,"userMuted":false},"video":{"screenShare":false,"camera":false,"blind":false}},"state":"JOINED","disconnected":false,"callId":"72a7bd33-c874-4aac-b874-e2c173c5061e","role":null},{"streams":{},"endpoint":{"type":"WEBRTC","identity":"customer"},"media":{"audio":{"muted":false,"deaf":false,"userMuted":false},"video":{"screenShare":false,"camera":false,"blind":false}},"state":"JOINED","disconnected":false,"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","role":null}]}
[InfobipCallKit][Client] event → established
[Example] established
[InfobipCallKit][FreeCallVM] event=established phase=connecting direction=incoming
[INFO] Received message from Portunus: {"event":"joined_video_conference"}
[INFO] Received message from Portunus: {"event":"setup_data_channel","description":{"type":"offer","sdp":"v=0\r\no=- 1784080642670283 1 IN IP4 81.23.249.62\r\ns=Janus TextRoom plugin\r\nt=0 0\r\na=group:BUNDLE 0\r\na=ice-options:trickle\r\na=fingerprint:sha-256 45:F4:34:CC:CC:8E:D4:FF:9F:09:D2:09:E4:DD:62:88:57:2A:69:65:B3:60:AC:EF:A7:F4:7E:14:82:E3:0F:3B\r\na=extmap-allow-mixed\r\na=msid-semantic: WMS *\r\na=ice-lite\r\nm=application 9 UDP/DTLS/SCTP webrtc-datachannel\r\nc=IN IP4 81.23.249.62\r\na=sendrecv\r\na=mid:0\r\na=sctp-port:5000\r\na=ice-ufrag:UjUZ\r\na=ice-pwd:i+bso0uZRzR6s6zQLwWRj4\r\na=ice-options:trickle\r\na=setup:actpass\r\na=candidate:1 1 udp 2015363327 81.23.249.62 28997 typ host\r\na=candidate:2 1 udp 2015363583 81.23.249.62 38655 typ host\r\na=end-of-candidates\r\n"},"id":"4eaac0db-9b7d-4e6d-900c-e800abc977a5@1456863.infobip.com"}
[InfobipCallKit][Client] event → audioRouteChanged(name: "iPhone")
[Example] audio route: iPhone
[InfobipCallKit][FreeCallVM] event=audioRouteChanged(InfobipCallKit.AudioRouteOption(id: "Built-In Microphone#0", name: "iPhone", kind: InfobipCallKit.AudioRouteOption.Kind.builtin, isActive: true)) phase=established direction=incoming
[INFO] audio peerConnection new connection state: connected
[INFO] Sending {"action":"ice_candidate_pair_selected","selectedCandidatePair":{"remote":{"type":"host","protocol":"udp","ip":"81.23.249.62","port":23139},"local":{"type":"prflx","protocol":"udp","ip":"171.231.207.196","port":5435}},"callId":"4a939278-9ade-4da0-a913-b5a28e2e7275"} to Infobip Gateway.
[INFO] Received message from Portunus: {"event":"hangup","callId":"4a939278-9ade-4da0-a913-b5a28e2e7275","status":{"id":10000,"name":"NORMAL_HANGUP","description":"The call has ended with hangup initiated by caller, callee or API."},"transaction":"42e0b54b-7395-4b2a-9206-5eff4d46f752"}
[INFO] audio peerConnection new connection state: disconnected
    AVAudioSession_iOS.mm:2540  Failed to set properties, error: '!pri'
[WARNING] Failed to set normal Audio mode after call: The operation couldn’t be completed. (OSStatus error 561017449.)
[INFO] audio peerConnection new connection state: closed
[INFO] peerConnection new signaling state: closed
[InfobipCallKit][ActiveCall] onHangup code=10000 name=NORMAL_HANGUP
[InfobipCallKit][Client] event → ended(InfobipCallKit.CallEndReason(code: 10000, name: "NORMAL_HANGUP", message: "The call has ended with hangup initiated by caller, callee or API.", isError: false))
[Example] call ended: NORMAL_HANGUP (code 10000, isError: false) — The call has ended with hangup initiated by caller, callee or API.
[InfobipCallKit][FreeCallVM] event=hangup(InfobipCallKit.CallEndReason(code: 10000, name: "NORMAL_HANGUP", message: "The call has ended with hangup initiated by caller, callee or API.", isError: false)) phase=established direction=incoming
[InfobipCallKit][FreeCallVM] finish wasEstablished=true local=false route=backToHome delay=2.0
[InfobipCallKit][CallKit] reportCallEnded uuid=4A939278-9ADE-4DA0-A913-B5A28E2E7275 reason=2
[INFO] Successfully submitted 9 logs
tcp_input [C3.1.1.1:3] flags=[R] seq=4090479398, ack=0, win=0 state=LAST_ACK rcv_nxt=4090479398, snd_una=593702845
tcp_input [C4.1.1.1:3] flags=[R] seq=2424790640, ack=0, win=0 state=LAST_ACK rcv_nxt=2424790640, snd_una=2588944053
[InfobipCallKit][FreeCallVM] triggering route backToHome