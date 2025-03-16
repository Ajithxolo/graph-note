### **📌 GraphNote - AI powered Note Management Application**  
*A GraphQL-powered application for managing notes efficiently across platforms.*  

---

## **🚀 Features**  

✅ **GraphQL API for Notes**  
- Create, update, and delete notes via GraphQL mutations.  
- Fetch notes with efficient query support.  

✅ **Service-Oriented Architecture**  
- **NoteService:** Handles business logic for note creation and updates.  
- **SentimentAnalysisService:** Processes sentiment insights for notes using OpenAi.  

✅ **Robust Data Validation & Sanitization**  
- Custom sanitization methods to prevent invalid inputs.  
- Ensures consistency before storing in the database.

---
## ** Demo and Documentation links**
- **Short demo URL** https://www.loom.com/share/4f65e834be184f30849cb149b465c6b1
- **Strong migration (created blog):** https://medium.com/@ajithbuddy/mastering-strong-migrations-my-journey-to-safer-rails-database-migrations-b829c2c6a3a7
---

## **📦 Tech Stack**  
- **Framework:** Ruby on Rails  
- **Database:** PostgreSQL  
- **GraphQL:** `graphql-ruby`  
- **Testing:** RSpec  
- **Frontend:** Loading..

---

## **🛠 Setup & Installation**  

### **🔹 Prerequisites**  
Ensure you have the following installed:  
- Ruby (>= 3.0)  
- Rails (>= 7.0)  
- PostgreSQL  
- Bundler  

### **🔹 Clone the Repository**  
```sh
git clone https://github.com/Ajithxolo/graph-note.git
```

### **🔹 Install Dependencies**  
```sh
bundle install
```

### **🔹 Setup Database**  
```sh
rails db:create
rails db:migrate
rails db:seed
```

### **🔹 Run the Server**  
```sh
rails s
```

### **🔹 Run Tests**  
```sh
bundle exec rspec
```

---

## **📖 API Usage**  

### **🔹 GraphQL Playground**  
Run the server and open:  
```
http://localhost:3000/graphiql
```

#### **Mutation Example: Create a Note**  
```graphql
mutation {
  createNote(input: { title: "New Note", body: "This is a test note" }) {
    note {
      id
      title
      body
    }
    errors
  }
}
```

---

## **📌 Contributing**  
1. Fork the repository.  
2. Create a feature branch: `git checkout -b feature-branch`  
3. Commit changes: `git commit -m "Add new feature"`  
4. Push to branch: `git push origin feature-branch`  
5. Open a Pull Request.  
