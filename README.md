# CQIS (Coffee Quality Inspection System)

>
> An AI-powered mobile application for automating the quality grading of Robusta Coffee Beans (*Coffea Canephora*) based on the Indonesian National Standard (SNI 01-2907-2008).

---

## About The Project

Grading coffee beans manually is a highly subjective and time-consuming process, taking up to 1.5 - 2 hours per kilogram. **CQIS** aims to digitalize and automate this process using an Object Detection approach.

By leveraging **YOLOv11** and **TensorFlow Lite**, this mobile application allows farmers, collectors, and distributors to detect 20 classes of coffee bean conditions (1 normal + 19 defects) directly from their Android smartphones without requiring an active internet connection (Offline-First).

This project is being developed as a part of a thesis research by **Fredli Fourqoni** at UIN Raden Intan Lampung.

---

## Key Features

### Current (Frontend / UI Phase)

- **Modern & Intuitive UI**: Designed specifically for accessibility and ease of use.
- **Clean Architecture**: Highly scalable folder structure separating Data, Domain, and Presentation layers.
- **Riverpod State Management**: Reactive and safe state handling.
- **Dynamic Data Visualization**: Integrated with `fl_chart` to display interactive defect breakdowns and final grades.

### Upcoming (AI & Backend Phase)

- **On-Device AI Inference**: Real-time object detection using optimized YOLOv11 `.tflite` model.
- **Automated Defect Calculation**: Calculates the Total Defect Value and outputs the final SNI Grade (Mutu 1 - Mutu 6).
- **Local & Cloud Storage**: Saving scan history securely.
- **PDF Report Export**: Export grading results to standard PDF formats.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| State Management | Riverpod |
| Routing | GoRouter |
| Charts | fl_chart |
| AI Model (Planned) | YOLOv11 (Ultralytics) → TensorFlow Lite |
| Database (Planned) | SQLite / Firebase |

---

## Getting Started

### Prerequisites

- Flutter SDK (Version 3.22 or higher recommended)
- Dart
- An IDE such as VS Code or Android Studio

### Installation

1. Clone the repository

```sh
   git clone https://github.com/fredli4qooni/cqis-mobile-app.git
```

2. Navigate to the project directory

```sh
   cd cqis-mobile-app
```

3. Install dependencies

```sh
   flutter pub get
```

4. Run the app on your emulator or physical device

```sh
   flutter run
```

---


## License

This project is licensed under the **PolyForm Noncommercial License 1.0.0**.

You may not use this software for commercial purposes. See the `LICENSE` file for more details.

---

*Designed and engineered for the future of Indonesian Coffee Quality.*