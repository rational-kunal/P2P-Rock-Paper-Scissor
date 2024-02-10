# (P2P) Rock Paper Scissor

Challenge your friends to a classic game of Rock Paper Scissor on a **peer-to-peer network** using this iOS project! Whether you're hosting or joining, simply choose your move and see who emerges victorious.

This project was created to explore the capabilities of **[Apple's Multipeer Connectivity framework](https://developer.apple.com/documentation/multipeerconnectivity)** for establishing peer-to-peer connections within the Apple ecosystem.

**Key Features:**

- **Simple and intuitive interface:** Host or join games with ease, and make your move with a single tap.
- **Real-time Results:** See your opponent's move and the outcome instantly.
- **Peer-to-peer Connection:** Play directly with friends without relying on an external server.

**Technical Details**

- **Modular Codebase:**
    - Models: Structs and enums encapsulating game state and UI data.
    - Services: GameSessionService managing session logic, networking, and state updates.
    - Views: Clear and responsive UI elements reflecting the game state.
    - ViewControllers: Orchestrating communication between components.
- **Key component:** `GameSessionService` manages game sessions, including host/join actions, data exchange, and game state maintenance
