# Pipeline Phân Tích Dữ Liệu Tiểu Đường (Diabetes Analysis Pipeline)

## 0. Header & Cấu hình tái lập
- **YAML output:** `html_document` + `pdf_document` (hoặc latex engine).
- **Setup:** `set.seed()`, `options` (knitr cache, fig.width/height), `session info`.
- **Load packages:**
  - Data import: `readr`...
  - Manipulation: `dplyr`/`data.table`
  - Visualization: `ggplot2`
  - Modeling: `tidymodels`/`caret`, `glmnet`, `nnet`, `MASS`, `e1071`
  - Imbalance handling: `themis` / `DMwR2` (nếu dùng SMOTE)
  - Evaluation: `broom`, `pROC`, `yardstick`

## 1. Proposal (B1) + Mục tiêu (B2)
### 1.1 Context ngắn
Bài toán screening risk tiểu đường từ dữ liệu **BRFSS 2015**.

### 1.2 Mục tiêu phân tích
Chốt 3–4 mục tiêu rõ ràng:
- **M1:** Mô tả dữ liệu + phân bố biến + phân bố target (0/1/2) và mức mất cân bằng.
- **M2:** Khám phá yếu tố liên quan đến tình trạng tiểu đường (univariate + hiệu ứng) và điều chỉnh multiple testing.
- **M3:** Xây dựng mô hình dự đoán (classification) cho nhiều “case” target do mất cân bằng; chọn case/model tốt nhất theo metric phù hợp.
- **(Tuỳ chọn) M4:** Diễn giải mô hình (odds ratio/feature importance) + gợi ý ứng dụng sàng lọc.

## 2. Data Ingestion + Data Dictionary
- **Đọc dữ liệu:** Đọc file CSV, kiểm tra schema (22 biến), kiểu dữ liệu.
- **Chuyển đổi biến:**
  - Map biến dạng `0/1` thành `factor`.
  - Biến thứ bậc (*Age, Education, Income, GenHlth*) thành `ordered factor` (hoặc numeric ordinal, nhưng phải nhất quán).
- **Ghi chú:** Thêm ghi chú ngắn về ý nghĩa biến (trích codebook/kaggle link trong text, không cần parse pdf codebook).

## 3. Data Quality Check (QC) + Missing Data (Lecture 06)
- **Kiểm tra:** NA, giá trị ngoài miền hợp lệ (`0/1`, range BMI, …).
- **Xử lý Missing Data (nếu có):**
  - Xác định pattern (MCAR/MAR giả định).
  - Chọn chiến lược: `complete-case` vs `imputation` (simple/multiple imputation) — ghi rõ lý do chọn.
- **Báo cáo kết quả QC:** Bảng số liệu (số NA theo biến, min/max, tần suất giá trị bất thường).

## 4. Định nghĩa bài toán “Cases” (Quan trọng)
Vì target 3 lớp lệch mạnh, chốt tối thiểu 2 hướng và so sánh:
- **Case A (Multiclass):** `0` vs `1` vs `2` (multinomial).
- **Case B (Binary):** `2` vs `(0+1)` (Tiểu đường vs Còn lại).
- **Case C (Binary):** `(1+2)` vs `0` (Nguy cơ/Tiền + Tiểu đường vs Không).
- **(Tuỳ chọn) Case D (Binary):** `1` vs `0` (Tiền tiểu đường vs Không) nếu đủ mẫu.

> **Yêu cầu trong .Rmd:**
> - Bảng count + proportion cho từng case.
> - Lý do chọn metric: do imbalance nên ưu tiên **Balanced Accuracy**, **Macro F1**, và **AUC (one-vs-rest)** thay vì accuracy thuần.

## 5. Split Dữ liệu + Preprocessing
- **Split:** Tách train/test (stratified theo target của từng case).
- **(Tuỳ chọn):** Thêm validation hoặc CV folds (stratified).
- **Preprocessing:**
  - Scale/center numeric (*BMI, MentHlth, PhysHlth*, … nếu có).
  - Xử lý factor/ordinal.
  - (Nếu dùng `glmnet`) One-hot encoding.

## 6. Mô tả & Biểu diễn tổng hợp dữ liệu (B4)
Tạo các bảng/biểu đồ “core” (đủ để lên PDF):
- **Bảng summary numeric:** Mean/sd/median/IQR theo nhóm Diabetes (hoặc theo case).
- **Bar chart:** Cho biến nhị phân theo nhóm Diabetes (tỷ lệ *HighBP, HighChol, Smoker*…).
- **Density/Hist/Boxplot:** Cho *BMI* theo nhóm.
- **Heatmap/Corr:** Cho biến numeric (nếu hợp lý).
- **Kết luận nhanh (EDA):** Điểm nào khác biệt rõ nhất.

## 7. Phân tích Mục tiêu M2: Yếu tố liên quan + Multiple Testing (B3, B5)
Làm theo đúng lecture multiple testing:
- **Kiểm định:**
  - Categorical vs Target: Chi-square / Fisher (nếu cần).
  - Numeric vs Target: ANOVA / Kruskal (tuỳ phân phối).
- **Điều chỉnh P-value:** Thu p-value cho nhiều kiểm định ⇒ điều chỉnh **BH (FDR)** (có thể thêm Bonferroni để so sánh).
- **Báo cáo:**
  - Bảng top biến “liên quan” sau adjust (`p_adj`).
  - Kèm effect size đơn giản (chênh tỷ lệ / OR univariate / standardized mean diff).

## 8. Phân tích Mục tiêu M3: Mô hình dự đoán (B3, B5)
### Model Set
Bám đúng nội dung đã học:
- **Baseline:** Majority class / Naive baseline.
- **Classification:**
  - Logistic Regression (Binary).
  - Multinomial Logistic (Case A).
  - Naive Bayes.
  - LDA/QDA (nếu giả định hợp).
  - Regularized Logistic (`glmnet`: lasso/ridge; multinomial nếu Case A).
  - (Tuỳ chọn) GAM Logistic nếu muốn nonlinear.

### Imbalance Strategies
Phải thử “tất cả case” và chọn tốt nhất:
- Không xử lý (Baseline).
- Class Weights (nếu framework hỗ trợ).
- Downsample/Upsample trong train.
- SMOTE (nếu áp dụng được và không quá nặng).

### Evaluation (CV + Test)
- **CV trên train:** Để chọn hyperparameters (lambda, …) và chọn chiến lược imbalance.
- **Đánh giá trên test:**
  - Confusion Matrix.
  - Balanced Accuracy, Macro F1.
  - ROC/AUC (Binary) hoặc One-vs-Rest AUC (Multiclass).
  - PR-AUC cho case rất lệch (nếu làm được).

> **Output bắt buộc:**
> - 1 Bảng so sánh Model × Case × Strategy với các metric chính (xếp hạng).
> - 1–2 Plot: ROC (binary) / Macro metric barplot / Confusion heatmap.

## 9. Diễn giải & “Khuyến nghị” (B6)
- **Với Logistic/Multinomial:** OR và CI (có thể bootstrap CI nếu muốn bám lecture bootstrap).
- **Phân tích:** Liệt kê top predictors + chiều tác động.
- **Hạn chế:** Survey self-reported, năm 2015, imbalance, proxy variables.
- **Kết luận:** Case/model nào tốt nhất + Metric đạt được + Gợi ý dùng cho screening.

## 10. Phụ lục (Tuỳ chọn nhưng nên có)
- `SessionInfo`.
- Bảng mapping level cho *Age/Education/Income/GenHlth*.
- Chi tiết tham số CV.
- Các plot phụ.
