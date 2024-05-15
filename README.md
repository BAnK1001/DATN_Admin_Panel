# Shoes Shop Admin

This is the admin panel for the Shoes Shop application. It is built with Flutter and Firebase to manage products, orders, vendors, categories, users, and more.

## Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Dependencies](#dependencies)
- [Configuration](#configuration)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Features

- **User Authentication:** Login and logout functionality using Firebase Auth.
- **Dashboard:** Overview of the shop's key metrics and recent activities.
- **Product Management:** Add, update, delete, and view products.
- **Order Management:** Track and manage customer orders.
- **Vendor Management:** Manage vendor information and interactions.
- **Category Management:** Create and organize product categories.
- **Carousel Banners:** Manage promotional banners for the shop.
- **Cash Outs:** Handle cash out requests and transactions.
- **User Management:** Manage admin users and their roles.

## Project Structure

```plaintext
lib/
│
├── controllers/
│   └── route_manager.dart          # Handles routing within the app
├── resources/
│   ├── assets_manager.dart         # Manages app assets
│   └── styles_manager.dart         # Manages app styles
├── views/
│   ├── main/
│   │   ├── carousel_banners/       # Views for managing carousel banners
│   │   ├── cash_outs/              # Views for managing cash outs
│   │   ├── categories/             # Views for managing categories
│   │   ├── orders/                 # Views for managing orders
│   │   ├── products/               # Views for managing products
│   │   ├── users/                  # Views for managing users
│   │   └── vendors/                # Views for managing vendors
│   ├── widgets/
│   │   └── are_you_sure_dialog.dart # Widget for confirmation dialogs
│   ├── home_screen.dart            # Home screen view
│   └── main_screen.dart            # Main screen view
└── main.dart                       # Main entry point of the app
