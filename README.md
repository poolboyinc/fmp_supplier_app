# **FMP Supplier App**

A mobile application for party and event suppliers to manage their offerings, bookings, and customer interactions.

---

## **Overview**

**FMP Supplier App** is the supplier-facing component of the FMP platform, designed to empower vendors and event organizers to manage parties, track bookings, and interact with customers. This app works in conjunction with the consumer-facing application to create a seamless event discovery and booking ecosystem.

---

## **Features**

### **Authentication**
- Secure login for verified suppliers  
- Firebase Authentication integration  
- Role-based access control  

### **Party Management**
- Create and publish new party events  
- Set start and end times  
- Specify location with interactive map selection  
- Upload cover images and logos  
- Configure pricing categories  
- Feature parties for increased visibility  
- Edit or update existing parties  
- Track party metrics and performance  

### **Booking Management**
- View and manage incoming bookings  
- Accept or decline booking requests  
- Message customers about their bookings  
- Track booking history and statistics  
- Manage capacity and availability  

### **Location Services**
- Mapbox integration for precise location selection  
- Interactive maps for customers to find events  
- Location-based search and discovery  

### **Real-time Updates**
- Firebase integration for instant booking notifications  
- Live updates to party details and availability  
- Synchronized data between supplier and consumer apps  

---

## **Technical Implementation**

- **Flutter** framework for cross-platform compatibility  
- **BLoC** pattern for state management  
- **Firebase services** (Authentication, Firestore, Storage)  
- **Mapbox** for location services  
- **Clean architecture** approach with separation of concerns  

---

## **Getting Started**

### **Prerequisites**
- Flutter SDK (latest version)  
- Firebase project setup  
- Mapbox API key  
- Android Studio / VS Code with Flutter plugins  

### **Installation**
1. Clone the repository  
2. Create a `.env` file in the root directory with the following variable:

   ```env
   MAPBOX_ACCESS_TOKEN=your_mapbox_token_here
3. Run **flutter pub get** to install dependencies
4. Configure Firebase according to the instructions in firebase_setup.md
5. Run the app using: **flutter run**

### **Contributing**
This project is licensed under the GNU General Public License v3.0.
While we appreciate feedback and bug reports, the codebase is proprietary and not open for public contributions.

### **Copyright**
© 2025 FMP Global Inc.

### Important Notice
This application is proprietary software developed by FMP Global Inc.
The source code is available for review under the terms of the GPL v3.0 license, but unauthorized copying, modification, or distribution beyond the terms of this license is strictly prohibited.

While the GPL allows for code sharing, please note that this application's branding, visual design, and business logic represent significant intellectual property. If you wish to create a similar application, you are encouraged to develop your own implementation rather than directly copying this work.

### Disclaimer
This application is not affiliated with Mapbox, Firebase, or any other third-party services it utilizes.
All third-party trademarks are the property of their respective owners.

