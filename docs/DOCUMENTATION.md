# AstroLearn — Complete Project Documentation

> A production-grade Vedic Astrology learning & analysis mobile app built with Flutter + direct Free Astrology API integration.

**Last Updated:** February 28, 2026  
**Version:** 2.0 - Special Days & Yogas Release

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [What's New in v2.0](#whats-new-in-v20)
3. [Tech Stack](#tech-stack)
4. [Project Structure](#project-structure)
5. [Backend (Flask API)](#backend-flask-api)
6. [Core Layer](#core-layer)
7. [Features](#features)
8. [Shared Widgets](#shared-widgets)
9. [Data Flow](#data-flow)
10. [Setup & Running](#setup--running)
11. [API Reference](#api-reference)
12. [Testing](#testing)

---

## Architecture Overview

```
┌──────────────────────────────────────────────────┐
│                   Flutter App                     │
│                                                   │
│  ┌──────────┐  ┌──────────┐  ┌───────────────┐   │
│  │ Features  │  │  Shared  │  │     App       │   │
│  │ (Screens) │  │ (Widgets)│  │ (Theme/Routes)│   │
│  └─────┬─────┘  └──────────┘  └───────────────┘   │
│        │                                          │
│  ┌─────▼──────────────────────────────────────┐   │
│  │              Core Layer                     │   │
│  │  ┌────────┐ ┌────────┐ ┌────────────────┐  │   │
│  │  │Services│ │ Astro  │ │   Database     │  │   │
│  │  │(API,AI)│ │Engines │ │ (Hive/Models)  │  │   │
│  │  └───┬────┘ └────────┘ └────────────────┘  │   │
│  │      │                                      │   │
│  │  ┌───▼────┐ ┌────────┐ ┌──────────┐        │   │
│  │  │ Repos  │ │ Stores │ │Constants │        │   │
│  │  │(Cache) │ │(State) │ │  (Data)  │        │   │
│  │  └────────┘ └────────┘ └──────────┘        │   │
│  └─────────────────────────────────────────────┘   │
└──────────────────────┬───────────────────────────┘
                       │ HTTP
              ┌────────▼────────┐
              │   Flask Backend  │
              │  (Chart Proxy)   │
              └────────┬─────────┘
                       │
              ┌────────▼────────┐
              │ Free Astrology  │
              │      API        │
              └─────────────────┘
```

---

## What's New in v2.0

### 🌟 Vedic Special Combinations (Yogas) Feature

Complete implementation of Vedic astrology's special day detection system:

