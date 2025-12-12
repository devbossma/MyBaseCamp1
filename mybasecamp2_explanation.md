# MyBasecamp 2 - Feature Requirements Explained

## 📚 **Terminology & Concepts**

### **Core Terms**

1. **Project** - A workspace where team members collaborate
2. **Attachment** - Files uploaded to a project (images, PDFs, documents)
3. **Thread** - A discussion topic within a project (like a forum thread)
4. **Message** - Individual posts/replies within a thread
5. **Project Admin** - The user who created the project (project owner)
6. **Associated Users** - Users assigned/invited to work on a project

---

## 🎯 **Feature 1: Attachments**

### **What is an Attachment?**

An attachment is a **file** that users can upload and associate with a project.

**Examples:**
- Project design mockups (PNG, JPG)
- Documentation (PDF, TXT, DOCX)
- Spreadsheets (XLS, CSV)
- Any other project-related files

### **Requirements Breakdown**

#### **Attachment#create** (Upload Files)
```
WHO: Any user associated with the project
WHAT: Upload files to the project
WHERE: Project detail page
FORMAT: PNG, JPG, PDF, TXT, or any file type
```

**User Story:**
> As a project team member, I want to upload design files to the project so that everyone can access them.

#### **Attachment#destroy** (Delete Files)
```
WHO: File uploader OR project admin
WHAT: Delete an uploaded attachment
WHEN: When file is no longer needed
```

**User Story:**
> As a user, I want to delete outdated files I uploaded to keep the project clean.

### **Database Schema**

```ruby
create_table "attachments", force: :cascade do |t|
  t.string "filename", null: false           # Original filename
  t.string "file_path", null: false          # Where file is stored
  t.string "file_type"                       # MIME type (image/png, application/pdf)
  t.integer "file_size"                      # Size in bytes
  t.integer "user_id", null: false           # Who uploaded it
  t.integer "project_id", null: false        # Which project
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end
```

### **How It Works**

```
User Flow:
1. User goes to Project detail page
2. Clicks "Upload File" button
3. Selects file from computer
4. File uploads to server
5. Attachment record created in database
6. File appears in attachments list
7. Other team members can download it
```

### **UI/UX Example**

```
┌─────────────────────────────────────┐
│ Project: Website Redesign           │
├─────────────────────────────────────┤
│ Description: ...                    │
│                                     │
│ 📎 Attachments (3)                  │
│ ┌─────────────────────────────────┐│
│ │ 📄 design-mockup.pdf  2.3 MB    ││
│ │ Uploaded by Alice - 2h ago      ││
│ │ [Download] [Delete]             ││
│ ├─────────────────────────────────┤│
│ │ 🖼️ logo.png  156 KB             ││
│ │ Uploaded by Bob - 1d ago        ││
│ │ [Download] [Delete]             ││
│ ├─────────────────────────────────┤│
│ │ 📝 requirements.txt  4 KB       ││
│ │ Uploaded by You - 3d ago        ││
│ │ [Download] [Delete]             ││
│ └─────────────────────────────────┘│
│ [+ Upload New File]                 │
└─────────────────────────────────────┘
```

---

## 🎯 **Feature 2: Threads (Discussion Topics)**

### **What is a Thread?**

A thread is a **discussion topic** where team members can have conversations about specific aspects of the project.

**Think of it like:**
- Forum threads
- Slack channels
- Email threads
- Reddit posts

**Examples:**
- "Design Feedback"
- "Bug Reports"
- "Feature Requests"
- "Weekly Updates"
- "Q&A Session"

### **Requirements Breakdown**

#### **Thread#new** (Create Discussion)
```
WHO: Only the project admin (project owner)
WHAT: Create a new discussion topic
WHY: Organize conversations by topic
```

**User Story:**
> As a project admin, I want to create a "Design Review" thread so the team can discuss design decisions separately from other topics.

#### **Thread#edit** (Update Thread)
```
WHO: Only the project admin
WHAT: Edit thread title/description
WHEN: To clarify or update the topic
```

#### **Thread#destroy** (Delete Thread)
```
WHO: Only the project admin
WHAT: Delete entire thread and all its messages
WHEN: When thread is no longer relevant
```

### **Database Schema**

```ruby
create_table "threads", force: :cascade do |t|
  t.string "title", null: false              # Thread topic
  t.text "description"                       # Optional details
  t.integer "project_id", null: false        # Which project
  t.integer "user_id", null: false           # Who created it (admin)
  t.boolean "pinned", default: false         # Pin to top?
  t.boolean "locked", default: false         # Prevent new messages?
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end
```

### **UI/UX Example**

```
┌─────────────────────────────────────┐
│ Project: Website Redesign           │
├─────────────────────────────────────┤
│ 💬 Discussions                       │
│                                     │
│ [+ New Thread] (Admin only)         │
│                                     │
│ ┌─────────────────────────────────┐│
│ │ 📌 Design Feedback              ││
│ │ Let's discuss the new UI...     ││
│ │ 12 messages • Last: 5m ago      ││
│ │ [View] [Edit] [Delete]          ││
│ ├─────────────────────────────────┤│
│ │ 🐛 Bug Reports                  ││
│ │ Report any issues here          ││
│ │ 8 messages • Last: 2h ago       ││
│ │ [View] [Edit] [Delete]          ││
│ ├─────────────────────────────────┤│
│ │ ✨ Feature Requests             ││
│ │ Suggest new features            ││
│ │ 15 messages • Last: 1d ago      ││
│ │ [View] [Edit] [Delete]          ││
│ └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

---

## 🎯 **Feature 3: Messages (Posts in Threads)**

### **What is a Message?**

A message is a **post/reply** within a thread. It's the actual conversation content.

**Think of it like:**
- Comments on a blog post
- Replies in a forum thread
- Messages in Slack
- Tweets in a Twitter thread

### **Requirements Breakdown**

#### **Message#new** (Post Message)
```
WHO: Any user associated with the project
WHAT: Write and post a message in a thread
WHERE: Inside a thread
```

**User Story:**
> As a team member, I want to reply to the "Design Feedback" thread with my thoughts so everyone can see my input.

#### **Message#edit** (Update Message)
```
WHO: Message author OR project admin
WHAT: Edit the message content
WHEN: To fix typos or add information
```

#### **Message#destroy** (Delete Message)
```
WHO: Message author OR project admin
WHAT: Remove a message from the thread
WHEN: Message is inappropriate or outdated
```

### **Database Schema**

```ruby
create_table "messages", force: :cascade do |t|
  t.text "content", null: false              # Message text
  t.integer "thread_id", null: false         # Which thread
  t.integer "user_id", null: false           # Who posted it
  t.integer "parent_message_id"              # For threaded replies
  t.datetime "edited_at"                     # Track edits
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end
```

### **UI/UX Example**

```
┌─────────────────────────────────────┐
│ Thread: Design Feedback             │
│ Let's discuss the new UI design     │
├─────────────────────────────────────┤
│ 💬 12 Messages                       │
│                                     │
│ ┌─────────────────────────────────┐│
│ │ 👤 Alice • 2h ago               ││
│ │ I love the new color scheme!    ││
│ │ The blue gradient is perfect.   ││
│ │ [Edit] [Delete] [Reply]         ││
│ │                                 ││
│ │   ↳ 👤 Bob • 1h ago             ││
│ │     Agreed! Much better than    ││
│ │     the old design.             ││
│ │     [Edit] [Delete]             ││
│ ├─────────────────────────────────┤│
│ │ 👤 Charlie • 30m ago            ││
│ │ Can we make the font bigger?    ││
│ │ [Edit] [Delete] [Reply]         ││
│ └─────────────────────────────────┘│
│                                     │
│ ┌─────────────────────────────────┐│
│ │ Write your message...           ││
│ │                                 ││
│ │ [📎 Attach] [Send]              ││
│ └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

---

## 🏗️ **System Architecture**

### **Data Relationships**

```
User ──┬──< Projects (owner)
       └──< ProjectAssignments (member)

Project ──┬──< Attachments
          ├──< Threads
          └──< ProjectAssignments

Thread ──< Messages

Message ──< User (author)
        └──< ParentMessage (optional, for replies)

Attachment ──< User (uploader)
```

### **Permission Matrix**

| Action | Project Admin | Team Member | Guest |
|--------|--------------|-------------|-------|
| View Project | ✅ | ✅ | ❌ |
| Upload Attachment | ✅ | ✅ | ❌ |
| Delete Own Attachment | ✅ | ✅ | ❌ |
| Delete Any Attachment | ✅ | ❌ | ❌ |
| Create Thread | ✅ | ❌ | ❌ |
| Edit Thread | ✅ | ❌ | ❌ |
| Delete Thread | ✅ | ❌ | ❌ |
| Post Message | ✅ | ✅ | ❌ |
| Edit Own Message | ✅ | ✅ | ❌ |
| Edit Any Message | ✅ | ❌ | ❌ |
| Delete Own Message | ✅ | ✅ | ❌ |
| Delete Any Message | ✅ | ❌ | ❌ |

---

## 📊 **Complete Database Schema**

```ruby
# schema.rb for MyBasecamp 2

ActiveRecord::Schema.define(version: 2025_12_15_000000) do

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], unique: true
    t.index ["username"], unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "user_id", null: false           # Project admin
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"]
  end

  create_table "project_assignments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id", null: false
    t.string "role", default: "member"         # member, viewer
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "project_id"], unique: true
  end

  # NEW: Attachments
  create_table "attachments", force: :cascade do |t|
    t.string "filename", null: false
    t.string "file_path", null: false
    t.string "content_type"                    # image/png, application/pdf
    t.integer "file_size"                      # bytes
    t.integer "user_id", null: false           # uploader
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"]
    t.index ["user_id"]
  end

  # NEW: Threads
  create_table "threads", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "project_id", null: false
    t.integer "user_id", null: false           # creator (admin)
    t.boolean "pinned", default: false
    t.boolean "locked", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"]
  end

  # NEW: Messages
  create_table "messages", force: :cascade do |t|
    t.text "content", null: false
    t.integer "thread_id", null: false
    t.integer "user_id", null: false           # author
    t.integer "parent_message_id"              # for nested replies
    t.datetime "edited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thread_id"]
    t.index ["user_id"]
    t.index ["parent_message_id"]
  end

  add_foreign_key "projects", "users"
  add_foreign_key "project_assignments", "users"
  add_foreign_key "project_assignments", "projects"
  add_foreign_key "attachments", "users"
  add_foreign_key "attachments", "projects"
  add_foreign_key "threads", "projects"
  add_foreign_key "threads", "users"
  add_foreign_key "messages", "threads"
  add_foreign_key "messages", "users"
end
```

---

## 🎬 **User Flows**

### **Flow 1: Uploading an Attachment**

```
1. User navigates to Project detail page
2. Scrolls to "Attachments" section
3. Clicks "Upload File" button
4. File picker dialog opens
5. User selects file (e.g., design.pdf)
6. File uploads with progress bar
7. Success message appears
8. Attachment appears in list
9. Other team members can download it
```

### **Flow 2: Creating a Discussion Thread**

```
1. Project admin goes to Project page
2. Clicks on "Discussions" tab
3. Clicks "New Thread" button
4. Fills in:
   - Title: "Design Review"
   - Description: "Let's discuss the mockups"
5. Clicks "Create Thread"
6. Thread appears in list
7. Team members can now post messages
```

### **Flow 3: Posting a Message**

```
1. User opens a Thread
2. Reads existing messages
3. Scrolls to bottom
4. Types message in text box
5. (Optional) Clicks "Attach File"
6. Clicks "Post Message"
7. Message appears instantly
8. Other users see notification
```

---

## 🎨 **UI/UX Mockup - Complete Project Page**

```
╔══════════════════════════════════════════════════════════╗
║ Project: Website Redesign                     [Edit] [⚙️] ║
╠══════════════════════════════════════════════════════════╣
║ Tabs: [Overview] [Discussions] [Attachments] [Members]  ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║ 📋 Overview Tab                                          ║
║ ─────────────────────────────────────────────────────── ║
║ Description: Redesigning our company website...         ║
║                                                          ║
║ 👥 Team: Alice (Admin), Bob, Charlie                    ║
║ 📅 Created: Dec 1, 2025                                 ║
║ ⏱️ Updated: 2 hours ago                                  ║
║                                                          ║
║ ─────────────────────────────────────────────────────── ║
║                                                          ║
║ 💬 Discussions Tab                                       ║
║ ─────────────────────────────────────────────────────── ║
║ [+ New Thread] (Admin only)                             ║
║                                                          ║
║ 📌 Pinned                                                ║
║ ┌────────────────────────────────────────────────────┐ ║
║ │ 📋 Project Kickoff                                  │ ║
║ │ Initial planning and requirements                   │ ║
║ │ 23 messages • Last: Alice, 10m ago                  │ ║
║ └────────────────────────────────────────────────────┘ ║
║                                                          ║
║ Recent                                                   ║
║ ┌────────────────────────────────────────────────────┐ ║
║ │ 🎨 Design Feedback                                  │ ║
║ │ Share your thoughts on the mockups                  │ ║
║ │ 15 messages • Last: Bob, 1h ago                     │ ║
║ └────────────────────────────────────────────────────┘ ║
║ ┌────────────────────────────────────────────────────┐ ║
║ │ 🐛 Bug Reports                                      │ ║
║ │ Report issues and bugs here                         │ ║
║ │ 7 messages • Last: Charlie, 3h ago                  │ ║
║ └────────────────────────────────────────────────────┘ ║
║                                                          ║
║ ─────────────────────────────────────────────────────── ║
║                                                          ║
║ 📎 Attachments Tab                                       ║
║ ─────────────────────────────────────────────────────── ║
║ [+ Upload File]                                          ║
║                                                          ║
║ ┌────────────────────────────────────────────────────┐ ║
║ │ 📄 wireframe-v2.pdf                      2.3 MB     │ ║
║ │ Uploaded by Alice • 2 hours ago                     │ ║
║ │ [Download] [Delete]                                 │ ║
║ ├────────────────────────────────────────────────────┤ ║
║ │ 🖼️ logo-variants.png                    1.2 MB     │ ║
║ │ Uploaded by Bob • 1 day ago                         │ ║
║ │ [Download] [Delete]                                 │ ║
║ ├────────────────────────────────────────────────────┤ ║
║ │ 📊 analytics-report.xlsx                856 KB     │ ║
║ │ Uploaded by Charlie • 3 days ago                    │ ║
║ │ [Download] [Delete]                                 │ ║
║ └────────────────────────────────────────────────────┘ ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
```

---

## ✅ **Implementation Checklist**

### **Phase 1: Attachments**
- [ ] Create Attachment model and migration
- [ ] Add file upload form to project page
- [ ] Implement file storage (local or cloud)
- [ ] Create attachment controller (create, destroy)
- [ ] Display attachments list with download links
- [ ] Add file type icons (PDF, image, etc.)
- [ ] Implement permission checks
- [ ] Add file size limits

### **Phase 2: Threads**
- [ ] Create Thread model and migration
- [ ] Add "Discussions" tab to project page
- [ ] Create thread list view
- [ ] Implement thread creation (admin only)
- [ ] Add thread edit/delete (admin only)
- [ ] Show message count per thread
- [ ] Add pinned threads feature

### **Phase 3: Messages**
- [ ] Create Message model and migration
- [ ] Create thread detail page
- [ ] Implement message posting
- [ ] Add message edit/delete
- [ ] Show message timestamps
- [ ] Display "edited" indicator
- [ ] Add nested replies (optional)
- [ ] Real-time updates (optional)

### **Phase 4: Cloud Deployment**
- [ ] Choose hosting (AWS EC2, Heroku, etc.)
- [ ] Setup Docker container
- [ ] Configure production database
- [ ] Setup file storage (S3, etc.)
- [ ] Deploy application
- [ ] Add deployment URL to README
- [ ] Setup SSL certificate
- [ ] Configure monitoring

---

## 🎯 **Key Differences from MyBasecamp 1**

| Feature | MyBasecamp 1 | MyBasecamp 2 |
|---------|--------------|--------------|
| Comments | ✅ Basic comments on projects | ✅ Still available |
| Attachments | ❌ Not available | ✅ **NEW** - Upload files |
| Discussions | ❌ Not available | ✅ **NEW** - Organized threads |
| Messages | ❌ Not available | ✅ **NEW** - Posts in threads |
| Team Collaboration | ⚠️ Basic | ✅ **Enhanced** |
| Hosting | ⚠️ Local | ✅ **Cloud-based** |

---

This is a significant upgrade that transforms MyBasecamp from a simple project tracker into a full **collaboration platform** like Slack or Basecamp! 🚀