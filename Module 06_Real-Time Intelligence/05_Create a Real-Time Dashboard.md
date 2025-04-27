# Create a Real-Time Dashboard

# 🚀 Real-Time Intelligence Tutorial Part 5: Create a Real-Time Dashboard

## 📝 Steps Overview

### 1. Create a Real-Time Dashboard

1. **Run the following query** in your KQL queryset:

   ```kusto
   AggregatedData
   | sort by BikepointID
   | render columnchart with (ycolumns=No_Bikes, xcolumn=BikepointID)
   ```

   This query returns a column chart showing the most recent number of bikes by `BikepointID`.

2. **Pin the query to a new dashboard**:

   - Select **Pin to dashboard**.

![image](https://github.com/user-attachments/assets/7799cfa5-8d40-4c52-8ac5-285245fb0c31)

   - Enter the following details:
     - **Create new tile**: In a new dashboard
     - **Dashboard name**: `TutorialDashboard`
     - **Tile name**: `Recent bikes by Bikepoint`
     - **Open dashboard after creation**: Selected
   - Select **Create**.

   The new Real-Time dashboard, `TutorialDashboard`, opens with the `Recent bikes by Bikepoint` tile.

![image](https://github.com/user-attachments/assets/0a0153dd-8597-4358-8d4e-7df27553ece5)


---

### 2. Add a New Tile to the Dashboard

1. **Switch to Editing mode**:

   - On the top menu bar, toggle from **Viewing mode** to **Editing mode**.

2. **Add a new tile**:

   - Select **New tile**.

3. **Enter the following query** in the query editor:

   ```kusto
   RawData
   | where Neighbourhood == "London Bridge"
   ```


4. **Apply changes**:

   - From the menu ribbon, select **Apply changes**. A new tile is created.

5. **Rename the tile**:

   - Select the **More menu** (`...`) on the top right corner of the tile.
   - Select **Rename tile**.
   - Enter the new name: `London Bridge bikes`.
   - 
![image](https://github.com/user-attachments/assets/7948fa06-2b70-4a97-b0dd-608c7606c4d7)

---

### 3. Explore the Data Visually by Adding an Aggregation

1. **Open the exploration tool**:

   - On the new `Chelsea bikes` tile, select the **Explore icon**.

2. **Add an aggregation**:

   - Select **+ Add > Aggregation**.
   - Configure the aggregation:
     - **Operator**: `max`
     - **Column**: `No_Bikes`
     - **Display Name**: `Max_Bikes`
   - Select **Apply**.

3. **Group by street**:

   - Select **+ Add grouping**.
   - Configure the grouping:
     - **Group by**: `Street`
   - Select **Apply**.

4. **Change the visual type**:

   - Change the **Visual type** to **Bar chart**.

5. **Pin the visualization to the dashboard**:

   - Select **Pin to dashboard**.
   - In the **Pin to dashboard** window, select **In this dashboard** > name the Tile as **max_bikes_street_wise**

![image](https://github.com/user-attachments/assets/8b425faf-ce05-45c4-a929-cd827e743e9a)

---

### 4. Add a Map Tile

1. **Add a new tile**:

   - Select **New tile**.

2. **Enter the following query** in the query editor:

   ```kusto
   RawData
   | where Timestamp > ago(1h)
   ```

3. **Add a map visual**:

   - Above the results pane, select **+ Add visual**.
   - In the **Visual formatting** pane, configure the visual:
     - **Tile name**: `Bike locations Map`
     - **Visual type**: `Map`
     - **Define location by**: `Latitude and longitude`
     - **Latitude column**: `Latitude`
     - **Longitude column**: `Longitude`
     - **Label column**: `BikepointID`
   - Select **Apply changes**.

4. **Resize and adjust the map**:

   - Resize the map tile and zoom in as desired.

---

### 5. Save the Dashboard

- Select the **Save icon** on the top left corner of the dashboard to save your changes.

---

## ✅ Goal

You have now created a Real-Time Dashboard with multiple tiles, including a column chart, bar chart, and map, to visualize your streaming data.

---

# Reference
[Create a Real-Time Dashboard](https://learn.microsoft.com/en-us/fabric/real-time-intelligence/tutorial-5-create-dashboard)
