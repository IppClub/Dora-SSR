import {createAgentSessionFeed,type AgentSessionEnvelope} from './agent-session-feed';

/** Attach only to trusted host subscriptions. Serialization is validated before
 * transport; a failed delivery retires this generation instead of reusing IDs.
 * Transport acceptance is not a durable receiver acknowledgement.
 */
export function createAgentSessionPublisher(projectId:string,generation:string,sessionId:number,
  send:(event:AgentSessionEnvelope)=>void,afterSequence=0) {
  const validator=createAgentSessionFeed(projectId,generation,sessionId,afterSequence);
  let active=true,publishing=false;
  return {
    publish(payload:string) {
      if(!active) throw new Error('Agent event publisher is retired');
      if(publishing) {active=false;throw new Error('Reentrant Agent event publication requires resync');}
      publishing=true;
      try {
        const event:AgentSessionEnvelope={version:1,projectId,generation,sessionId,sequence:validator.sequence+1,payload};
        if(validator.receive(event).status!=='accepted') throw new Error('Invalid Agent event requires resync');
        send(Object.freeze(event));
        if(!active) throw new Error('Agent event publisher retired during delivery');
        return event.sequence;
      } catch(error) {active=false;throw error;}
      finally {publishing=false;}
    },
    close(){active=false;},
    get active(){return active;},
    get sequence(){return validator.sequence;},
  };
}
