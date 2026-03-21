# Voyant
## game. travel. explore. 

A gamified traveling platform that provides users with quests that they can embark on. This quest based approach will allow the user to explore tourist spots and discover certain places that are less visited. Following a core story-line the user will be guided to primary landmarks along with side missions as supplementary tasks. This will be displayed all in a map view with the users avatar representing their location. This will also incorporate some AR elements providing a more engaging experience to the user. 

## Overview of the prototype

- The front end is built with Flutter using the BLoC pattern, Firebase Core, and Google Maps/Geolocator integrations to deliver a gamified travel experience. Users interact through quests, skill trees, avatars/cosmetics, inventory, group travel, and business partner flows, with cross‑platform support (mobile, desktop, and web) via a single codebase.
- The backend is implemented with Node.js and Express, organized into modular routes and controllers for quests, avatars, destinations, user progress, rewards, messaging, and groups. Firebase Admin is used for authentication, and a RESTful JSON API design keeps configuration, routing, and model definitions cleanly separated for maintainability.
- MongoDB, accessed through Mongoose, stores core game data including quests, tasks, triggers, destinations, user skills, progress, trips, rewards, and avatars. Firestore security rules further govern partner data access for business integrations, ensuring protected CRUD operations and a smooth experience across client and server.
