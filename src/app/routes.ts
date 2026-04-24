import { createBrowserRouter } from "react-router";
import Root from "./Root";
import Home from "./pages/Home";
import Login from "./pages/Login";
import Register from "./pages/Register";
import Onboarding from "./pages/Onboarding";
import ReservationMap from "./pages/ReservationMap";
import MyReservations from "./pages/MyReservations";
import StudyBuddy from "./pages/StudyBuddy";
import Profile from "./pages/Profile";
import CourseRating from "./pages/CourseRating";
import LostFound from "./pages/LostFound";
import WeeklySchedule from "./pages/WeeklySchedule";
import NotFound from "./pages/NotFound";
import ErrorBoundary from "./pages/ErrorBoundary";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: Root,
    ErrorBoundary: ErrorBoundary,
    children: [
      { index: true, Component: Login },
      { path: "register", Component: Register },
      { path: "onboarding", Component: Onboarding },
      { path: "home", Component: Home },
      { path: "reserve", Component: ReservationMap },
      { path: "my-reservations", Component: MyReservations },
      { path: "study-buddy", Component: StudyBuddy },
      { path: "profile", Component: Profile },
      { path: "course-rating", Component: CourseRating },
      { path: "lost-found", Component: LostFound },
      { path: "weekly-schedule", Component: WeeklySchedule },
      { path: "*", Component: NotFound },
    ],
  },
]);