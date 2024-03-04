# LiveView Polling Application

PollApp is an interactive web application built with Elixir, Phoenix, and LiveView. It allows users to create polls, vote on them, and see real-time updates without needing to refresh the page. This document provides setup instructions, an overview of how the application works, and explanations of key design decisions and trade-offs.

## Setup Instructions

### Prerequisites
- Elixir 1.12 or later
- Phoenix 1.5 or later

### Usage
- Install Dependencies
```mix deps.get```
- Start the Phoenix Server
```mix phx.server```
Alternatively, you can run your app inside IEx (Interactive Elixir) to have access to your application’s debugging features:
```iex -S mix phx.server```
The application is now accessible at ```localhost:4000``` from your browser.

## Key Features
- User session management for tracking active users.
- Real-time updates of polls and votes using Phoenix LiveView.
- GenServer-based state management for user sessions and polls.

## How it works
### User Session Management
Upon visiting the application, users are prompted to enter a username. The PollAppWeb.SessionController checks if the username exists in the session. If not, it handles new or returning visitors by either rendering the homepage for new visitors or redirecting logged-in users to the polls page.

The PollApp.UserSessionManager is a GenServer responsible for managing user sessions. It tracks active usernames and prevents duplicate usernames.

### Poll Management
The PollApp.PollsManager is another GenServer responsible for creating, listing, voting on, and deleting polls. It maintains a state of all polls and their respective votes. Polls can be created with multiple options, and users can vote on these options. Real-time updates on poll creation, voting, and deletion are broadcasted using Phoenix PubSub.

### Design Decisions and Trade-offs
GenServer for State Management: Using GenServer for managing user sessions and polls provides a concurrent and fault-tolerant solution. However, this means that the state is held in memory, leading to potential data loss on application restarts. A more persistent solution could be implemented for production use.
Real-time Updates with LiveView: Phoenix LiveView allows for real-time communication with the client without the need for custom JavaScript. This simplifies the development process but relies heavily on WebSockets, which may not be supported in all network environments.
### Session-based Authentication

Authentication is handled through sessions, which simplifies the process but does not offer the same level of security as token-based authentication systems.
### Conclusion
PollApp demonstrates the power of Elixir and Phoenix for building real-time, interactive web applications. By leveraging GenServer and LiveView, it offers a responsive user experience with real-time feedback. While there are trade-offs in terms of state persistence and authentication security, these decisions were made to focus on the real-time interactive features of the application. Future improvements could include persistent state storage and enhanced security measures.
