<div class="mermaid">
classDiagram
    direction LR

    %% ===== Core class =====
    class Agent {
        -MutableAgentState _state
        -Set listeners
        -PendingMessageQueue steeringQueue
        -PendingMessageQueue followUpQueue
        -ActiveRun activeRun
        +convertToLlm
        +transformContext
        +streamFn: StreamFn
        +getApiKey
        +onPayload
        +onResponse
        +beforeToolCall
        +afterToolCall
        +sessionId?: string
        +thinkingBudgets?: ThinkingBudgets
        +transport: Transport
        +maxRetryDelayMs?: number
        +toolExecution: ToolExecutionMode
        +constructor(options: AgentOptions)
        +subscribe(listener) : ()=>void
        +get state() AgentState
        +steer(message)
        +followUp(message)
        +clearSteeringQueue()
        +clearFollowUpQueue()
        +clearAllQueues()
        +hasQueuedMessages() bool
        +get signal() AbortSignal
        +abort()
        +waitForIdle() Promise
        +reset()
        +prompt(input, images?) Promise
        +continue() Promise
        -runPromptMessages()
        -runContinuation()
        -createContextSnapshot() AgentContext
        -createLoopConfig() AgentLoopConfig
        -runWithLifecycle()
        -handleRunFailure()
        -finishRun()
        -processEvents(event: AgentEvent)
    }

    class PendingMessageQueue {
        -AgentMessage[] messages
        +mode: QueueMode
        +enqueue(message)
        +hasItems() bool
        +drain() AgentMessage[]
        +clear()
    }

    class ActiveRun {
        +promise: Promise
        +resolve: ()=>void
        +abortController: AbortController
    }

    %% ===== Options / state interfaces =====
    class AgentOptions {
        <<interface>>
        +initialState?
        +convertToLlm?
        +transformContext?
        +streamFn?: StreamFn
        +getApiKey?
        +onPayload?
        +onResponse?
        +beforeToolCall?
        +afterToolCall?
        +steeringMode?: QueueMode
        +followUpMode?: QueueMode
        +sessionId?
        +thinkingBudgets?
        +transport?
        +maxRetryDelayMs?
        +toolExecution?: ToolExecutionMode
    }

    class AgentState {
        <<interface>>
        +systemPrompt: string
        +model: Model
        +thinkingLevel: ThinkingLevel
        +tools: AgentTool[]
        +messages: AgentMessage[]
        +isStreaming: bool
        +streamingMessage?: AgentMessage
        +pendingToolCalls: ReadonlySet
        +errorMessage?: string
    }

    class AgentContext {
        <<interface>>
        +systemPrompt: string
        +messages: AgentMessage[]
        +tools?: AgentTool[]
    }

    %% ===== Loop / tool config =====
    class AgentLoopConfig {
        <<interface>>
        +model: Model
        +convertToLlm
        +transformContext?
        +getApiKey?
        +getSteeringMessages?
        +getFollowUpMessages?
        +toolExecution?: ToolExecutionMode
        +beforeToolCall?
        +afterToolCall?
    }

    class AgentTool {
        <<interface>>
        +label: string
        +prepareArguments?
        +execute(toolCallId, params, signal?, onUpdate?)
        +executionMode?: ToolExecutionMode
    }

    class AgentToolResult {
        <<interface>>
        +content: (TextContent|ImageContent)[]
        +details: T
        +terminate?: bool
    }

    class BeforeToolCallContext {
        <<interface>>
        +assistantMessage
        +toolCall: AgentToolCall
        +args: unknown
        +context: AgentContext
    }
    class BeforeToolCallResult {
        <<interface>>
        +block?: bool
        +reason?: string
    }
    class AfterToolCallContext {
        <<interface>>
        +assistantMessage
        +toolCall: AgentToolCall
        +args: unknown
        +result: AgentToolResult
        +isError: bool
        +context: AgentContext
    }
    class AfterToolCallResult {
        <<interface>>
        +content?
        +details?
        +isError?: bool
        +terminate?: bool
    }

    %% ===== Events / messages =====
    class AgentEvent {
        <<union type>>
        agent_start | agent_end
        turn_start | turn_end
        message_start | message_update | message_end
        tool_execution_start | _update | _end
    }

    class AgentMessage {
        <<union type>>
        Message | CustomAgentMessages
    }

    class CustomAgentMessages {
        <<interface, extensible>>
    }

    %% ===== Loop entry-point functions =====
    class agent_loop_module {
        <<module: agent-loop.ts>>
        +agentLoop(prompts, ctx, cfg, signal?, streamFn?) EventStream
        +agentLoopContinue(ctx, cfg, signal?, streamFn?) EventStream
        +runAgentLoop(...) Promise
        +runAgentLoopContinue(...) Promise
        +AgentEventSink
    }

    %% ===== Proxy =====
    class ProxyMessageEventStream {
        +constructor()
    }
    class EventStream {
        <<external, pi-ai>>
    }
    class ProxyStreamOptions {
        <<interface>>
        +signal?: AbortSignal
        +authToken: string
        +proxyUrl: string
    }
    class ProxyAssistantMessageEvent {
        <<union type>>
        start|text_*|thinking_*|toolcall_*|done|error
    }
    class proxy_module {
        <<module: proxy.ts>>
        +streamProxy(model, ctx, options) ProxyMessageEventStream
        -buildProxyRequestOptions(options)
        -processProxyEvent(event, partial)
    }

    %% ===== External types (pi-ai) =====
    class Model { <<external>> }
    class Tool { <<external>> }
    class Message { <<external>> }
    class SimpleStreamOptions { <<external>> }
    class StreamFn { <<type alias>> }

    %% ===== Relationships =====
    Agent "1" *-- "2" PendingMessageQueue : owns steering & followUp
    Agent "1" o-- "0..1" ActiveRun : current run
    Agent ..> AgentOptions : configured by
    Agent ..> AgentState : exposes
    Agent ..> AgentContext : creates snapshot
    Agent ..> AgentLoopConfig : creates
    Agent ..> AgentEvent : emits / processes
    Agent ..> AgentMessage : transcript items
    Agent ..> agent_loop_module : delegates to runAgentLoop / runAgentLoopContinue

    agent_loop_module ..> AgentContext
    agent_loop_module ..> AgentLoopConfig
    agent_loop_module ..> AgentEvent
    agent_loop_module ..> AgentMessage
    agent_loop_module ..> AgentTool
    agent_loop_module ..> StreamFn

    AgentLoopConfig --|> SimpleStreamOptions : extends
    AgentLoopConfig ..> Model
    AgentLoopConfig ..> BeforeToolCallContext
    AgentLoopConfig ..> AfterToolCallContext
    AgentLoopConfig ..> BeforeToolCallResult
    AgentLoopConfig ..> AfterToolCallResult

    AgentState ..> Model
    AgentState ..> AgentTool
    AgentState ..> AgentMessage

    AgentContext ..> AgentTool
    AgentContext ..> AgentMessage

    AgentTool --|> Tool : extends
    AgentTool ..> AgentToolResult : produces

    BeforeToolCallContext ..> AgentContext
    AfterToolCallContext  ..> AgentContext
    AfterToolCallContext  ..> AgentToolResult

    AgentMessage ..> Message
    AgentMessage ..> CustomAgentMessages

    ProxyMessageEventStream --|> EventStream : extends
    proxy_module ..> ProxyMessageEventStream : returns
    proxy_module ..> ProxyStreamOptions : input
    proxy_module ..> ProxyAssistantMessageEvent : parses
    Agent ..> proxy_module : optional streamFn = streamProxy
