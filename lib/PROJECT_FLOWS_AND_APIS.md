# Project flows and API integration cross-check

This document maps app flows to APIs and notes how features relate.

---

## 1. Auth flow

| Step | Screen / action | API | Repository | ViewModel |
|------|------------------|-----|------------|-----------|
| Login | LoginScreen → Submit | `POST auth/auth/login` | AuthRepository.login | LoginScreenViewModel |
| Signup | SignUpScreen → Submit | `POST auth/auth/signup` | AuthRepository.signUp | SignupScreenViewModel |
| Token refresh (on 401) | BaseApiService retry | `POST auth/auth/refresh` | AuthRepository.refresh | — |
| Logout | Dashboard → Logout | `POST auth/auth/logout` | AuthRepository.logout | — |

- **Navigation:** Login success → `pushReplacementNamed(dashboardScreen)`. Signup success → `pushReplacementNamed(loginScreen)`. Logout → `pushReplacementNamed(loginScreen)`.
- **Token:** Stored in `AuthTokenStore`; `BaseApiService` uses it for all authenticated requests and triggers refresh on 401.

---

## 2. Dashboard

| Action | API | Repository | ViewModel |
|--------|-----|------------|-----------|
| Load overview | `GET dashboard/dashboard/` | DashboardRepository.getDashboard | DashboardViewModel |

- **When:** `DashboardOverviewContent` calls `fetchDashboard()` in `initState` (post-frame).
- **Data:** Total employees, active/resigned/on-hold, total assets, in use, in store, **damaged**, **under repair**, recent employees, recent assets. Stats (e.g. damaged count) come from this API, not from damage/repair list APIs.

---

## 3. Employees

| Action | API | Repository | ViewModel |
|--------|-----|------------|-----------|
| List | `GET employees/employees/` (query: status, department, page, limit) | EmployeeRepository.getEmployees | EmployeeScreenViewModel |
| Create | `POST employees/employees/` | EmployeeRepository.createEmployee | EmployeeScreenViewModel |
| Update | `PATCH employees/employees/{id}/` | EmployeeRepository.updateEmployee | EmployeeScreenViewModel |
| Detail | `GET employees/employees/{id}/` | EmployeeRepository.getEmployeeDetail | EmployeeScreenViewModel |

- **When:** EmployeeScreen fetches on init. Assign Asset screen also fetches employees (and assets) on init.

---

## 4. Assets

| Action | API | Repository | ViewModel |
|--------|-----|------------|-----------|
| List | `GET assets/assets/` (query: category, current_status, page, limit) | AssetRepository.getAssets | AssetsScreenViewModel |
| Create | `POST assets/assets/` | AssetRepository.createAsset | AssetsScreenViewModel |
| Update | `PATCH assets/assets/{id}/` | AssetRepository.updateAsset | AssetsScreenViewModel |
| Delete | `DELETE assets/assets/{id}/` | AssetRepository.deleteAsset | AssetsScreenViewModel |
| Return to store | `POST assets/assets/{id}/return` | AssetRepository.returnAssetToStore | AssetsScreenViewModel |
| Report damage | `POST assets/assets/{id}/report-damage` (query: employee_id, reason, damage_date) | AssetRepository.reportDamage | AssetsScreenViewModel |
| Assign to employee | `POST assets/assets/assign` (query: employee_id, notes; body: asset ids) | AssetRepository.assignAssetsToEmployee | AssetsScreenViewModel |
| Import | `POST assets/assets/import` (multipart file) | AssetRepository.importAssets | AssetsScreenViewModel |
| Export | `GET assets/assets/export` | AssetRepository.exportAssets | AssetsScreenViewModel |

- **Report damage:** Opens ReportDamageDialog (employee, reason, date) → `reportDamage()` → asset list updated; asset can then appear in **Damaged Assets** (see below).
- **Assign:** Assign Asset screen uses AssetsScreenViewModel + EmployeeScreenViewModel; calls `assignAssetsToEmployee()`.

---

## 5. Damaged assets (damage flow)

| Action | API | Repository | ViewModel |
|--------|-----|------------|-----------|
| List damaged | `GET damage/damaged/` | DamageRepository.getDamagedAssets | DamagedAssetsScreenViewModel |
| Send to repair | `POST damage/damaged/{asset_id}/send-to-repair` (body: asset_id, repair_status, repair_notes, repair_cost, sent_date, completed_date) | DamageRepository.sendToRepair | DamagedAssetsScreenViewModel |
| Remove permanently | `DELETE damage/damaged/{asset_id}/remove` | DamageRepository.removeDamagedAsset | DamagedAssetsScreenViewModel |

- **When:** DamagedAssetsScreenContent fetches `fetchDamagedAssets()` on init.
- **Flow:** Assets screen **Report damage** → backend marks asset damaged → **Damaged Assets** list (GET damage/damaged/) shows it. From there user can **Send to repair** (POST send-to-repair) or **Remove** (DELETE remove).
- **Send to repair:** Dialog for optional notes/cost → API → on success item is removed from damaged list locally. Backend creates a repair record (used by Repair Management when list API exists).

---

## 6. Repair management

| Action | API | Repository | ViewModel |
|--------|-----|------------|-----------|
| Update status | `PUT damage/damaged/{repair_id}/update` (body: repair_status, repair_notes, repair_cost, completed_date) | DamageRepository.updateRepairStatus | RepairManagementScreenViewModel |

- **List:** Repair list is currently **demo data** (`kDemoRepairEntries`). There is no "list repairs" or "under repair" API in `api_constants.dart`. When the backend adds such an endpoint, the ViewModel should fetch that list and use returned `repair_id`s for **Update repair status**.
- **Flow:** User selects **Mark Fixed** / **Under Repair** / **Not Repairable** → `updateRepairStatus(repairId, status)` → PUT update → local list updated on success.
- **Interrelation:** Items that appear in Repair Management (once list is real) come from **Send to repair** on Damaged Assets. Update status (Fixed / Not Repairable) is done here.

---

## 7. Store inventory

| Action | API | Repository | ViewModel |
|--------|-----|------------|-----------|
| List store assets | `GET store/store/` | StoreRepository.getStoreAssets | StoreInventoryScreenViewModel |

- **When:** Store inventory screen fetches on init.

---

## 8. Asset reports

| Action | API | Repository | ViewModel |
|--------|-----|------------|-----------|
| History | `GET reports/reports/history` (query: period) | ReportsRepository.getAssetHistory | AssetReportsScreenViewModel |

- **When:** Asset reports screen fetches on init.

---

## 9. Profile

| Action | API | Repository | ViewModel |
|--------|-----|------------|-----------|
| Get profile | `GET profile/profile/me` | ProfileRepository.getProfile | ProfileManagementScreenViewModel |
| Update profile | `PUT profile/profile/update` | ProfileRepository.updateProfile | ProfileManagementScreenViewModel |
| Change password | `POST profile/profile/change-password` | ProfileRepository.changePassword | ProfileManagementScreenViewModel |

- **When:** Profile screen fetches on init.

---

## 10. Provider wiring (main.dart)

- **Repositories:** Auth, Dashboard, Employee, Asset, Store, **Damage**, Reports, Profile (all use `apiWithAuth` except Auth which uses it for logout/refresh and unauthenticated for login/signup).
- **ViewModels:** Dashboard, Employee, Assets, Store, **DamagedAssets**, **RepairManagement**, AssetReports, Profile, Login (authRepo + tokenStore), Signup (authRepo).
- **DamageRepository** is shared by **DamagedAssetsScreenViewModel** and **RepairManagementScreenViewModel**.

---

## 11. Interrelation summary

- **Report damage (Assets)** → asset marked damaged on backend → **Damaged list** (GET damage/damaged/) shows it.
- **Damaged Assets:** **Send to repair** → POST send-to-repair → item removed from damaged list; backend has a repair record. **Remove** → DELETE remove → item removed from list and backend.
- **Repair Management:** **Update status** (Fixed / Not Repairable / Pending) uses PUT update with `repair_id`. List is still demo; when backend adds a list/under-repair API, wire it here and use real `repair_id`s.
- **Dashboard** counts (damaged, under repair) come from **dashboard API**, not from damage or repair list APIs.
- **Assign flow:** Assign Asset screen → assign API with employee_id and asset ids; assets list is refreshed after success.

---

## 12. Gaps / recommendations

1. **Repair list API:** Repair Management screen uses `kDemoRepairEntries`. When backend provides e.g. `GET damage/damaged/repairs/` or similar, add the endpoint, a `DamageRepository.getRepairs()` (or equivalent), and in `RepairManagementScreenViewModel` replace the demo list with a fetch; use the returned `id` as `repair_id` for `updateRepairStatus`.
2. **Consistency:** All feature screens that depend on lists (employees, assets, damaged, store, reports, profile) fetch on init and use the same pattern (loading, error, retry/clearError). Repair Management is the only one still on demo data for the list.
3. **Error handling:** 422 responses are parsed for `detail[].msg` in damage and profile repositories; same pattern is used for send-to-repair, update-repair, and remove-damaged.

---

## 13. Verification checklist (endpoint → screen)

| Endpoint / feature | Repository method | ViewModel | Screen / trigger |
|-------------------|-------------------|-----------|------------------|
| Auth: login | AuthRepository.login | LoginScreenViewModel | LoginScreen submit |
| Auth: signup | AuthRepository.signUp | SignupScreenViewModel | SignUpScreen submit |
| Auth: refresh | AuthRepository.refresh | — | BaseApiService on 401 |
| Auth: logout | AuthRepository.logout | — | Dashboard logout |
| GET dashboard | DashboardRepository.getDashboard | DashboardViewModel | DashboardOverviewContent init |
| GET employees | EmployeeRepository.getEmployees | EmployeeScreenViewModel | EmployeeScreen, AssignAssetScreen init |
| POST employee | EmployeeRepository.createEmployee | EmployeeScreenViewModel | EmployeeScreen add |
| PATCH employee | EmployeeRepository.updateEmployee | EmployeeScreenViewModel | EmployeeScreen edit |
| GET employee detail | EmployeeRepository.getEmployeeDetail | EmployeeScreenViewModel | EmployeeScreen detail |
| GET assets | AssetRepository.getAssets | AssetsScreenViewModel | AssetsScreen, AssignAssetScreen init |
| POST/PATCH/DELETE asset | AssetRepository create/update/delete | AssetsScreenViewModel | AssetsScreen CRUD |
| POST return | AssetRepository.returnAssetToStore | AssetsScreenViewModel | AssetsScreen return |
| POST report-damage | AssetRepository.reportDamage | AssetsScreenViewModel | AssetsScreen report damage dialog |
| POST assign | AssetRepository.assignAssetsToEmployee | AssetsScreenViewModel | AssignAssetScreen assign |
| GET/POST import, export | AssetRepository import/export | AssetsScreenViewModel | AssetsScreen import/export |
| GET store | StoreRepository.getStoreAssets | StoreInventoryScreenViewModel | StoreInventoryScreen init |
| GET damaged | DamageRepository.getDamagedAssets | DamagedAssetsScreenViewModel | DamagedAssetsScreen init + retry |
| POST send-to-repair | DamageRepository.sendToRepair | DamagedAssetsScreenViewModel | DamagedAssetsScreen Send to repair |
| DELETE remove damaged | DamageRepository.removeDamagedAsset | DamagedAssetsScreenViewModel | DamagedAssetsScreen Remove confirm |
| PUT update repair | DamageRepository.updateRepairStatus | RepairManagementScreenViewModel | RepairManagementScreen Mark Fixed / Not repairable |
| GET reports/history | ReportsRepository.getAssetHistory | AssetReportsScreenViewModel | AssetReportsScreen init |
| GET/PUT profile, change password | ProfileRepository get/update/changePassword | ProfileManagementScreenViewModel | ProfileManagementScreen |

---

*Last cross-check: all integrated APIs are wired constants → repository → ViewModel → screen (Provider). Only repair list is pending a backend list API.*
