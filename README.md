# ChatApp

ChatApp is a real-time messaging application built with Ruby on Rails, allowing users to register, sign in, send messages (including to themselves), and receive real-time notifications for unread messages. The application features a clean, responsive UI with a notification system and role-based access control.

## Features and Technologies

### 1. User Authentication
- **Description**: Users can sign up, sign in, and sign out securely. Authentication ensures only authorized users can access the chat features.
- **Technologies and Gems**:
  - **Devise**: Handles user registration, authentication, and session management.
    - Gem: `gem 'devise'`
  - **Ruby on Rails**: Manages user sessions and routes (`config/routes.rb`).
  - **ERB (Embedded Ruby)**: Renders sign-in and sign-up forms (`app/views/devise/*`).
  - **PostgreSQL**: Stores user data (e.g., email, encrypted password) in the `users` table.

### 2. Role-Based Authorization
- **Description**: Users have roles (e.g., admin, regular user), and access to chat features is restricted based on roles. Admins can initiate chats with any user, while regular users can only respond to admin-initiated chats or message themselves.
- **Technologies and Gems**:
  - **CanCanCan**: Implements role-based authorization rules.
    - Gem: `gem 'cancancan'`
    - Configuration: `app/models/ability.rb` defines rules like `can :chat_with, User`.
  - **Ruby on Rails**: Controller actions (`ChatsController`) check permissions using `authorize!`.
  - **ActiveRecord**: Queries users based on roles (`User.select { |u| can?(:chat_with, u) }`).

### 3. Real-Time Messaging
- **Description**: Users can send and receive messages in real-time, with messages displayed in a chat interface. Messages are styled differently for the sender and receiver, with edit and delete options for the sender’s messages.
- **Technologies and Gems**:
  - **ActionCable**: Enables real-time WebSocket communication for message updates.
    - Gem: `gem 'actioncable'` (included in Rails).
    - Configuration: `app/channels/chat_channel.rb` broadcasts messages to `chat_#{sender_id}_#{receiver_id}`.
  - **Ruby on Rails**: `ChatsController` handles message creation, updating, and deletion.
  - **ActiveRecord**: `Chat` model (`app/models/chat.rb`) stores messages with `sender_id`, `receiver_id`, `message`, and `read` columns.
  - **jQuery**: Handles dynamic message rendering and AJAX for edit/delete (`app/views/chats/show.html.erb`).
    - Gem: `gem 'jquery-rails'`.
  - **Bootstrap**: Styles the chat interface with cards and responsive layouts.
    - CDN: `https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css`.
  - **ERB**: Renders the chat UI (`app/views/chats/show.html.erb`).

### 4. Self-Messaging
- **Description**: Users can send messages to themselves, useful for notes or reminders. Self-messages are treated as unread until viewed, appearing in the notification system.
- **Technologies and Gems**:
  - **Ruby on Rails**: `ChatsController` allows `sender_id == receiver_id` without restrictions.
  - **ActiveRecord**: `Chat` model supports self-messages with the same schema.
  - **ActionCable**: Broadcasts self-messages to the same channel (`chat_#{user_id}_#{user_id}`).
  - **ERB**: Displays “(you or message yourself!)” in the user list (`app/views/chats/index.html.erb`).

### 5. Notification Icon with Unread Count and Dropdown
- **Description**: A bell icon in the navbar displays the total number of unread messages. Clicking it reveals a dropdown listing up to five unread messages, each linking to the corresponding chat. The count and dropdown update in real-time when new messages arrive or are read.
- **Technologies and Gems**:
  - **ActionCable**: `NotificationsChannel` (`app/channels/notifications_channel.rb`) broadcasts new messages and read updates to `notifications_#{user_id}`.
  - **Ruby on Rails**: 
    - `ChatsController#show` marks messages as read and broadcasts updated counts.
    - `Chat` model broadcasts new messages (`broadcast_notification`).
  - **ActiveRecord**: Queries unread messages (`Chat.where(receiver_id: current_user.id, read: false)`).
  - **jQuery**: Updates the badge (`$('#unread-count')`) and dropdown (`$('#notification-menu')`) in `app/views/layouts/application.html.erb`.
  - **Bootstrap**: Styles the dropdown and badge with `dropdown-menu` and `badge-danger`.
  - **Font Awesome**: Provides the bell icon.
    - CDN: `https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css`.
  - **SCSS**: Custom styles for the badge and dropdown (`app/assets/stylesheets/application.scss`).

### 6. Unread Message Badges in User List
- **Description**: The chat user list (`/chats`) shows a badge next to each user indicating the number of unread messages from them. Badges update in real-time.
- **Technologies and Gems**:
  - **ActionCable**: `NotificationsChannel` updates badges via `unread_count_per_sender`.
  - **Ruby on Rails**: `ChatsController#index` loads users and calculates unread counts.
  - **ActiveRecord**: Queries unread messages per sender (`Chat.where(sender_id: user.id, receiver_id: current_user.id, read: false).count`).
  - **jQuery**: Updates badges dynamically (`#unread-count-#{user.id}`) in `app/views/chats/index.html.erb`.
  - **Bootstrap**: Styles badges with `badge-primary badge-pill`.

### 7. Responsive and Animated UI
- **Description**: The app has a modern, responsive UI with animations for messages and cards, ensuring a smooth user experience across devices.
- **Technologies and Gems**:
  - **Bootstrap**: Provides responsive navbar, cards, and buttons.
  - **Animate.css**: Adds fade-in and slide-in animations for messages and cards.
    - CDN: `https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css`.
  - **Google Fonts**: Uses the Inter font for a clean look.
    - CDN: `https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700`.
  - **SCSS**: Custom gradients and styles (`app/assets/stylesheets/application.scss`).

## Project Setup

### Prerequisites
- Ruby 3.2.2
- Rails 5.2.x
- PostgreSQL 14.x
- Redis (optional, for ActionCable in production)
- Node.js (for asset pipeline)
- Yarn (for JavaScript dependencies)

### Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd chatapp
   ```
2. Install dependencies:
   ```bash
   bundle install
   yarn install
   ```
3. Set up the database:
   ```bash
   rails db:setup
   ```
4. Load environment variables (create `.env` if needed):
   ```bash
   export $(cat .env | xargs)
   ```
5. Precompile assets:
   ```bash
   rails assets:precompile
   ```
6. Start the server:
   ```bash
   rails server
   ```
7. Ensure PostgreSQL and Redis (if used) are running:
   ```bash
   sudo service postgresql start
   sudo service redis start
   ```

### Database Schema
- **Users Table** (`users`):
  - Columns: `id`, `email`, `encrypted_password`, `name`, `role`, `created_at`, `updated_at`.
  - Created by Devise with custom `name` and `role` columns.
- **Chats Table** (`chats`):
  - Columns: `id`, `sender_id`, `receiver_id`, `message`, `read` (boolean, NOT NULL, default: false), `created_at`, `updated_at`.
  - Associations: `belongs_to :sender, class_name: 'User'`, `belongs_to :receiver, class_name: 'User'`.

### Configuration
- **config/routes.rb**: Defines routes for authentication (`devise_for :users`), chats (`resources :chats`), and the root path (`root to: 'home#index'`).
- **config/cable.yml**: Configures ActionCable (`adapter: async` for development, `adapter: redis` for production).
- **app/models/ability.rb**: Defines CanCanCan rules for chat permissions.

## Usage
1. **Sign Up/Sign In**: Visit `/users/sign_up` or `/users/sign_in`.
2. **View Chats**: Go to `/chats` to see available users
