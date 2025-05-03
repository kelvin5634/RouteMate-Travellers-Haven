const express = require("express");
const mysql = require("mysql2/promise");
const bcrypt = require("bcrypt");
const session = require("express-session");
const path = require("path");
const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, "public")));
app.use(
  session({
    secret: "transport-management-secret",
    resave: false,
    saveUninitialized: true,
    cookie: { maxAge: 24 * 60 * 60 * 1000 }, // 24 hours
  })
);

// Set view engine
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

// Database connection
const dbConfig = {
  host: "localhost",
  user: "root",
  password: "",
  database: "transport_management",
};

// Create connection pool
const pool = mysql.createPool(dbConfig);

// Middleware to check if user is authenticated
const isAuthenticated = (req, res, next) => {
  if (req.session.user) {
    return next();
  }
  res.redirect("/login");
};

// Middleware to check if user is admin
const isAdmin = (req, res, next) => {
  if (req.session.user && req.session.user.role === "admin") {
    return next();
  }
  res.status(403).render("error", {
    message: "Access denied. Admin privileges required.",
    user: req.session.user || null,
  });
};

// Home page
app.get("/", async (req, res) => {
  try {
    const [routes] = await pool.query("SELECT * FROM routes LIMIT 6");
    const [vehicles] = await pool.query("SELECT * FROM vehicles LIMIT 3");

    res.render("index", {
      user: req.session.user || null,
      routes,
      vehicles,
    });
  } catch (error) {
    console.error("Error fetching home page data:", error);
    res.status(500).render("error", {
      message: "Error loading home page",
      user: req.session.user || null,
    });
  }
});

// Login page
app.get("/login", (req, res) => {
  if (req.session.user) {
    return res.redirect("/dashboard");
  }
  res.render("login", {
    user: null,
    error: null,
  });
});

// Login process
app.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    const [users] = await pool.query("SELECT * FROM users WHERE email = ?", [email]);

    if (users.length === 0) {
      return res.render("login", {
        user: null,
        error: "Invalid email or password",
      });
    }

    const user = users[0];
    const passwordMatch = await bcrypt.compare(password, user.password);

    if (!passwordMatch) {
      return res.render("login", {
        user: null,
        error: "Invalid email or password",
      });
    }

    // Store user in session
    req.session.user = {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    };

    if (user.role === "admin") {
      res.redirect("/admin/dashboard");
    } else {
      res.redirect("/dashboard");
    }
  } catch (error) {
    console.error("Login error:", error);
    res.render("login", {
      user: null,
      error: "An error occurred during login",
    });
  }
});

// Register page
app.get("/register", (req, res) => {
  if (req.session.user) {
    return res.redirect("/dashboard");
  }
  res.render("register", {
    user: null,
    error: null,
  });
});

// Register process
app.post("/register", async (req, res) => {
  try {
    const { name, email, password, confirmPassword } = req.body;

    // Validate input
    if (!name || !email || !password || !confirmPassword) {
      return res.render("register", {
        user: null,
        error: "All fields are required",
      });
    }

    if (password !== confirmPassword) {
      return res.render("register", {
        user: null,
        error: "Passwords do not match",
      });
    }

    // Check if email already exists
    const [existingUsers] = await pool.query("SELECT * FROM users WHERE email = ?", [email]);

    if (existingUsers.length > 0) {
      return res.render("register", {
        user: null,
        error: "Email already in use",
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert new user
    await pool.query("INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)", [
      name,
      email,
      hashedPassword,
      "passenger",
    ]);

    res.redirect("/login");
  } catch (error) {
    console.error("Registration error:", error);
    res.render("register", {
      user: null,
      error: "An error occurred during registration",
    });
  }
});

// Logout
app.get("/logout", (req, res) => {
  req.session.destroy();
  res.redirect("/");
});

// User dashboard
app.get("/dashboard", isAuthenticated, async (req, res) => {
  try {
    const [bookings] = await pool.query(
      `
      SELECT b.*, v.name as vehicle_name, r.origin, r.destination, s.departure_time, s.arrival_time 
      FROM bookings b
      JOIN schedules s ON b.schedule_id = s.id
      JOIN vehicles v ON s.vehicle_id = v.id
      JOIN routes r ON s.route_id = r.id
      WHERE b.user_id = ?
      ORDER BY b.created_at DESC
    `,
      [req.session.user.id]
    );

    res.render("dashboard", {
      user: req.session.user,
      bookings,
    });
  } catch (error) {
    console.error("Dashboard error:", error);
    res.status(500).render("error", {
      message: "Error loading dashboard",
      user: req.session.user,
    });
  }
});

// Vehicles page
app.get("/vehicles", async (req, res) => {
  try {
    const [vehicles] = await pool.query(`
      SELECT v.*, r.origin, r.destination 
      FROM vehicles v
      LEFT JOIN routes r ON v.route_id = r.id
    `);

    res.render("vehicles", {
      user: req.session.user || null,
      vehicles,
    });
  } catch (error) {
    console.error("Vehicles error:", error);
    res.status(500).render("error", {
      message: "Error loading vehicles",
      user: req.session.user || null,
    });
  }
});

// Routes page
app.get("/routes", async (req, res) => {
  try {
    const [routes] = await pool.query("SELECT * FROM routes");

    res.render("routes", {
      user: req.session.user || null,
      routes,
    });
  } catch (error) {
    console.error("Routes error:", error);
    res.status(500).render("error", {
      message: "Error loading routes",
      user: req.session.user || null,
    });
  }
});

// Schedules page
app.get("/schedules", async (req, res) => {
  try {
    const routeId = req.query.route_id;
    const date = req.query.date;

    // Get all routes for the dropdown
    const [routes] = await pool.query("SELECT * FROM routes");

    // Base query to get schedules
    let query = `
      SELECT s.*, r.origin, r.destination, v.name as vehicle_name, v.registration_number, v.capacity
      FROM schedules s
      JOIN routes r ON s.route_id = r.id
      JOIN vehicles v ON s.vehicle_id = v.id
    `;

    const params = [];
    const conditions = [];

    // Add conditions based on filters
    if (routeId && routeId !== "") {
      conditions.push("s.route_id = ?");
      params.push(routeId);
    }

    if (date && date !== "") {
      conditions.push("DATE(s.departure_time) = ?");
      params.push(date);
    } else {
      // If no date specified, show future schedules by default
      conditions.push("s.departure_time > NOW()");
    }

    if (conditions.length > 0) {
      query += " WHERE " + conditions.join(" AND ");
    }

    query += " ORDER BY s.departure_time ASC";

    const [schedules] = await pool.query(query, params);

    // Convert price to number
    schedules.forEach(schedule => {
      schedule.price = parseFloat(schedule.price);
    });


    res.render("schedules", {
      user: req.session.user || null,
      schedules,
      routes,
      selectedRoute: routeId || "",
      selectedDate: date || "",
    });
  } catch (error) {
    console.error("Schedules error:", error);
    res.status(500).render("error", {
      message: "Error loading schedules",
      user: req.session.user || null,
    });
  }
});

// Booking page
app.get("/book/:scheduleId", isAuthenticated, async (req, res) => {
  try {
    const { scheduleId } = req.params;

    const [schedules] = await pool.query(
      `
      SELECT s.*, r.origin, r.destination, v.name as vehicle_name, v.registration_number, v.capacity
      FROM schedules s
      JOIN routes r ON s.route_id = r.id
      JOIN vehicles v ON s.vehicle_id = v.id
      WHERE s.id = ?
    `,
      [scheduleId]
    );

    if (schedules.length === 0) {
      return res.status(404).render("error", {
        message: "Schedule not found",
        user: req.session.user,
      });
    }

    const schedule = schedules[0];
    schedule.price = parseFloat(schedule.price); // Convert price to number

    // Get booked seats
    const [bookings] = await pool.query("SELECT seat_number FROM bookings WHERE schedule_id = ?", [scheduleId]);
    const bookedSeats = bookings.map(booking => booking.seat_number);

    res.render("booking", {
      user: req.session.user,
      schedule,
      bookedSeats,
    });
  } catch (error) {
    console.error("Booking error:", error);
    res.status(500).render("error", {
      message: "Error loading booking page",
      user: req.session.user,
    });
  }
});

// Process booking
app.post("/book", isAuthenticated, async (req, res) => {
  try {
    const { scheduleId, seatNumber } = req.body;

    // Check if seat is already booked
    const [existingBookings] = await pool.query("SELECT * FROM bookings WHERE schedule_id = ? AND seat_number = ?", [
      scheduleId,
      seatNumber,
    ]);

    if (existingBookings.length > 0) {
      return res.status(400).json({ success: false, message: "Seat already booked" });
    }

    // Generate booking reference
    const bookingReference = Math.random().toString(36).substring(2, 10).toUpperCase();

    // Create booking
    await pool.query(
      "INSERT INTO bookings (user_id, schedule_id, seat_number, booking_reference, status) VALUES (?, ?, ?, ?, ?)",
      [req.session.user.id, scheduleId, seatNumber, bookingReference, "confirmed"]
    );

    res.json({ success: true, bookingReference });
  } catch (error) {
    console.error("Booking process error:", error);
    res.status(500).json({ success: false, message: "An error occurred during booking" });
  }
});

// Contact page
app.get("/contact", (req, res) => {
  res.render("contact", {
    user: req.session.user || null,
    success: null,
    error: null,
  });
});

// Process contact form
app.post("/contact", async (req, res) => {
  try {
    const { name, email, subject, message } = req.body;

    // Validate input
    if (!name || !email || !subject || !message) {
      return res.render("contact", {
        user: req.session.user || null,
        success: null,
        error: "All fields are required",
      });
    }

    // Save message to database
    await pool.query("INSERT INTO contact_messages (name, email, subject, message) VALUES (?, ?, ?, ?)", [
      name,
      email,
      subject,
      message,
    ]);

    res.render("contact", {
      user: req.session.user || null,
      success: "Your message has been sent successfully!",
      error: null,
    });
  } catch (error) {
    console.error("Contact form error:", error);
    res.render("contact", {
      user: req.session.user || null,
      success: null,
      error: "An error occurred while sending your message",
    });
  }
});

// Admin dashboard
app.get("/admin/dashboard", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const [vehicleCount] = await pool.query("SELECT COUNT(*) as count FROM vehicles");
    const [routeCount] = await pool.query("SELECT COUNT(*) as count FROM routes");
    const [bookingCount] = await pool.query("SELECT COUNT(*) as count FROM bookings");
    const [userCount] = await pool.query('SELECT COUNT(*) as count FROM users WHERE role = "passenger"');

    const [recentBookings] = await pool.query(`
      SELECT b.*, u.name as user_name, v.name as vehicle_name, r.origin, r.destination
      FROM bookings b
      JOIN users u ON b.user_id = u.id
      JOIN schedules s ON b.schedule_id = s.id
      JOIN vehicles v ON s.vehicle_id = v.id
      JOIN routes r ON s.route_id = r.id
      ORDER BY b.created_at DESC
      LIMIT 10
    `);

    res.render("admin/dashboard", {
      user: req.session.user,
      stats: {
        vehicles: vehicleCount[0].count,
        routes: routeCount[0].count,
        bookings: bookingCount[0].count,
        users: userCount[0].count,
      },
      recentBookings,
    });
  } catch (error) {
    console.error("Admin dashboard error:", error);
    res.status(500).render("error", {
      message: "Error loading admin dashboard",
      user: req.session.user,
    });
  }
});

// Admin vehicles
app.get("/admin/vehicles", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const [vehicles] = await pool.query(`
      SELECT v.*, r.origin, r.destination 
      FROM vehicles v
      LEFT JOIN routes r ON v.route_id = r.id
    `);

    const [routes] = await pool.query("SELECT * FROM routes");

    res.render("admin/vehicles", {
      user: req.session.user,
      vehicles,
      routes,
      success: null,
      error: null,
    });
  } catch (error) {
    console.error("Admin vehicles error:", error);
    res.status(500).render("error", {
      message: "Error loading admin vehicles",
      user: req.session.user,
    });
  }
});

// Add vehicle
app.post("/admin/vehicles", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const { name, registration_number, capacity, route_id } = req.body;

    // Validate input
    if (!name || !registration_number || !capacity) {
      const [vehicles] = await pool.query(`
        SELECT v.*, r.origin, r.destination 
        FROM vehicles v
        LEFT JOIN routes r ON v.route_id = r.id
      `);

      const [routes] = await pool.query("SELECT * FROM routes");

      return res.render("admin/vehicles", {
        user: req.session.user,
        vehicles,
        routes,
        success: null,
        error: "Name, registration number, and capacity are required",
      });
    }

    // Insert vehicle
    await pool.query("INSERT INTO vehicles (name, registration_number, capacity, route_id) VALUES (?, ?, ?, ?)", [
      name,
      registration_number,
      capacity,
      route_id || null,
    ]);

    res.redirect("/admin/vehicles");
  } catch (error) {
    console.error("Add vehicle error:", error);
    res.status(500).render("error", {
      message: "Error adding vehicle",
      user: req.session.user,
    });
  }
});

// Update vehicle
app.post("/admin/vehicles/update", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const { id, name, registration_number, capacity, route_id } = req.body;

    // Update vehicle
    await pool.query("UPDATE vehicles SET name = ?, registration_number = ?, capacity = ?, route_id = ? WHERE id = ?", [
      name,
      registration_number,
      capacity,
      route_id || null,
      id,
    ]);

    res.redirect("/admin/vehicles");
  } catch (error) {
    console.error("Update vehicle error:", error);
    res.status(500).render("error", {
      message: "Error updating vehicle",
      user: req.session.user,
    });
  }
});

// Delete vehicle
app.post("/admin/vehicles/delete", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const { id } = req.body;

    // Delete vehicle
    await pool.query("DELETE FROM vehicles WHERE id = ?", [id]);

    res.redirect("/admin/vehicles");
  } catch (error) {
    console.error("Delete vehicle error:", error);
    res.status(500).render("error", {
      message: "Error deleting vehicle",
      user: req.session.user,
    });
  }
});

// Admin routes
app.get("/admin/routes", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const [routes] = await pool.query("SELECT * FROM routes");

    res.render("admin/routes", {
      user: req.session.user,
      routes,
      success: null,
      error: null,
    });
  } catch (error) {
    console.error("Admin routes error:", error);
    res.status(500).render("error", {
      message: "Error loading admin routes",
      user: req.session.user,
    });
  }
});

// Add route
app.post("/admin/routes", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const { origin, destination, distance, duration } = req.body;

    // Validate input
    if (!origin || !destination) {
      const [routes] = await pool.query("SELECT * FROM routes");

      return res.render("admin/routes", {
        user: req.session.user,
        routes,
        success: null,
        error: "Origin and destination are required",
      });
    }

    // Insert route
    await pool.query("INSERT INTO routes (origin, destination, distance, duration) VALUES (?, ?, ?, ?)", [
      origin,
      destination,
      distance || null,
      duration || null,
    ]);

    res.redirect("/admin/routes");
  } catch (error) {
    console.error("Add route error:", error);
    res.status(500).render("error", {
      message: "Error adding route",
      user: req.session.user,
    });
  }
});

// Update route
app.post("/admin/routes/update", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const { id, origin, destination, distance, duration } = req.body;

    // Update route
    await pool.query("UPDATE routes SET origin = ?, destination = ?, distance = ?, duration = ? WHERE id = ?", [
      origin,
      destination,
      distance || null,
      duration || null,
      id,
    ]);

    res.redirect("/admin/routes");
  } catch (error) {
    console.error("Update route error:", error);
    res.status(500).render("error", {
      message: "Error updating route",
      user: req.session.user,
    });
  }
});

// Delete route
app.post("/admin/routes/delete", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const { id } = req.body;

    // Delete route
    await pool.query("DELETE FROM routes WHERE id = ?", [id]);

    res.redirect("/admin/routes");
  } catch (error) {
    console.error("Delete route error:", error);
    res.status(500).render("error", {
      message: "Error deleting route",
      user: req.session.user,
    });
  }
});

// Admin schedules
app.get("/admin/schedules", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const routeId = req.query.route_id;
    const date = req.query.date;

    // Get all routes and vehicles for form
    const [routes] = await pool.query("SELECT * FROM routes");
    const [vehicles] = await pool.query("SELECT * FROM vehicles");

    // Base query to get schedules
    let query = `
      SELECT s.*, r.origin, r.destination, v.name as vehicle_name
      FROM schedules s
      JOIN routes r ON s.route_id = r.id
      JOIN vehicles v ON s.vehicle_id = v.id
    `;

    const params = [];
    const conditions = [];

    // Add conditions based on filters
    if (routeId && routeId !== "") {
      conditions.push("s.route_id = ?");
      params.push(routeId);
    }

    if (date && date !== "") {
      conditions.push("DATE(s.departure_time) = ?");
      params.push(date);
    }

    if (conditions.length > 0) {
      query += " WHERE " + conditions.join(" AND ");
    }

    query += " ORDER BY s.departure_time ASC";

    console.log("Admin schedule query:", query);
    console.log("Admin schedule params:", params);

    const [schedules] = await pool.query(query, params);

    // Convert price to number
    schedules.forEach(schedule => {
      schedule.price = parseFloat(schedule.price);
    });

    console.log(`Found ${schedules.length} admin schedules matching criteria`);
    console.log("Admin schedules:", JSON.stringify(schedules, null, 2));

    res.render("admin/schedules", {
      user: req.session.user,
      schedules,
      routes,
      vehicles,
      selectedRoute: routeId || "",
      selectedDate: date || "",
      success: null,
      error: null,
    });
  } catch (error) {
    console.error("Admin schedules error:", error);
    res.status(500).render("error", {
      message: "Error loading admin schedules",
      user: req.session.user,
    });
  }
});

// Add schedule
app.post("/admin/schedules", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const { route_id, vehicle_id, departure_time, arrival_time, price } = req.body;

    // Validate input
    if (!route_id || !vehicle_id || !departure_time || !arrival_time || !price) {
      const [schedules] = await pool.query(`
        SELECT s.*, r.origin, r.destination, v.name as vehicle_name
        FROM schedules s
        JOIN routes r ON s.route_id = r.id
        JOIN vehicles v ON s.vehicle_id = v.id
        ORDER BY s.departure_time ASC
      `);

      const [routes] = await pool.query("SELECT * FROM routes");
      const [vehicles] = await pool.query("SELECT * FROM vehicles");

      return res.render("admin/schedules", {
        user: req.session.user,
        schedules,
        routes,
        vehicles,
        selectedRoute: "",
        selectedDate: "",
        success: null,
        error: "All fields are required",
      });
    }

    // Insert schedule
    await pool.query(
      "INSERT INTO schedules (route_id, vehicle_id, departure_time, arrival_time, price) VALUES (?, ?, ?, ?, ?)",
      [route_id, vehicle_id, departure_time, arrival_time, price]
    );

    res.redirect("/admin/schedules");
  } catch (error) {
    console.error("Add schedule error:", error);
    res.status(500).render("error", {
      message: "Error adding schedule",
      user: req.session.user,
    });
  }
});

// Update schedule
app.post("/admin/schedules/update", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const { id, route_id, vehicle_id, departure_time, arrival_time, price } = req.body;

    // Update schedule
    await pool.query(
      "UPDATE schedules SET route_id = ?, vehicle_id = ?, departure_time = ?, arrival_time = ?, price = ? WHERE id = ?",
      [route_id, vehicle_id, departure_time, arrival_time, price, id]
    );

    res.redirect("/admin/schedules");
  } catch (error) {
    console.error("Update schedule error:", error);
    res.status(500).render("error", {
      message: "Error updating schedule",
      user: req.session.user,
    });
  }
});

// Delete schedule
app.post("/admin/schedules/delete", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const { id } = req.body;

    // Delete schedule
    await pool.query("DELETE FROM schedules WHERE id = ?", [id]);

    res.redirect("/admin/schedules");
  } catch (error) {
    console.error("Delete schedule error:", error);
    res.status(500).render("error", {
      message: "Error deleting schedule",
      user: req.session.user,
    });
  }
});

// Admin bookings
app.get("/admin/bookings", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const [bookings] = await pool.query(`
      SELECT b.*, u.name as user_name, u.email as user_email, 
             v.name as vehicle_name, r.origin, r.destination,
             s.departure_time, s.arrival_time
      FROM bookings b
      JOIN users u ON b.user_id = u.id
      JOIN schedules s ON b.schedule_id = s.id
      JOIN vehicles v ON s.vehicle_id = v.id
      JOIN routes r ON s.route_id = r.id
      ORDER BY b.created_at DESC
    `);

    res.render("admin/bookings", {
      user: req.session.user,
      bookings,
    });
  } catch (error) {
    console.error("Admin bookings error:", error);
    res.status(500).render("error", {
      message: "Error loading admin bookings",
      user: req.session.user,
    });
  }
});

// Update booking status
app.post("/admin/bookings/update-status", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const { id, status } = req.body;

    // Update booking status
    await pool.query("UPDATE bookings SET status = ? WHERE id = ?", [status, id]);

    res.redirect("/admin/bookings");
  } catch (error) {
    console.error("Update booking status error:", error);
    res.status(500).render("error", {
      message: "Error updating booking status",
      user: req.session.user,
    });
  }
});

// Admin contact messages
app.get("/admin/messages", isAuthenticated, isAdmin, async (req, res) => {
  try {
    const [messages] = await pool.query("SELECT * FROM contact_messages ORDER BY created_at DESC");

    res.render("admin/messages", {
      user: req.session.user,
      messages,
    });
  } catch (error) {
    console.error("Admin messages error:", error);
    res.status(500).render("error", {
      message: "Error loading admin messages",
      user: req.session.user,
    });
  }
});

// Error handling middleware
app.use((req, res) => {
  res.status(404).render("error", {
    message: "Page not found",
    user: req.session.user || null,
  });
});

// Start server
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});