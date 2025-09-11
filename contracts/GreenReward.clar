;; GreenReward - Decentralized Carbon Credit Marketplace with IoT Verification
;; A platform for issuing, trading, and retiring carbon credits with automated environmental monitoring

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_AMOUNT (err u101))
(define-constant ERR_INSUFFICIENT_BALANCE (err u102))
(define-constant ERR_CREDIT_NOT_FOUND (err u103))
(define-constant ERR_CREDIT_ALREADY_RETIRED (err u104))
(define-constant ERR_INVALID_PRICE (err u105))
(define-constant ERR_SELF_TRADE (err u106))
(define-constant ERR_INVALID_STRING (err u107))
(define-constant ERR_EMPTY_BATCH (err u108))
(define-constant ERR_BATCH_TOO_LARGE (err u109))
(define-constant ERR_SENSOR_NOT_FOUND (err u110))
(define-constant ERR_INVALID_SENSOR_DATA (err u111))
(define-constant ERR_VERIFICATION_THRESHOLD_NOT_MET (err u112))
(define-constant ERR_SENSOR_ALREADY_REGISTERED (err u113))
(define-constant ERR_INVALID_ORACLE (err u114))
(define-constant ERR_ARITHMETIC_OVERFLOW (err u115))
(define-constant ERR_INVALID_PRINCIPAL (err u116))
(define-constant MAX_BATCH_SIZE u50) ;; Maximum batch size for operations

;; Data Variables
(define-data-var next-credit-id uint u1)
(define-data-var next-sensor-id uint u1)
(define-data-var platform-fee uint u250) ;; 2.5% fee (250 basis points)

;; Data Maps
(define-map carbon-credits
  uint
  {
    issuer: principal,
    owner: principal,
    amount: uint,
    price-per-credit: uint,
    project-type: (string-ascii 50),
    verification-standard: (string-ascii 30),
    issue-date: uint,
    retired: bool,
    for-sale: bool,
    sensor-id: (optional uint),
    verification-status: (string-ascii 20),
    last-verified: (optional uint)
  }
)

(define-map user-balances
  principal
  {
    total-credits: uint,
    total-retired: uint
  }
)

(define-map marketplace-listings
  uint
  {
    seller: principal,
    price-per-credit: uint,
    available-amount: uint,
    listing-date: uint
  }
)

(define-map iot-sensors
  uint
  {
    sensor-address: (string-ascii 100),
    project-location: (string-ascii 100),
    sensor-type: (string-ascii 30),
    registered-by: principal,
    registration-date: uint,
    is-active: bool,
    last-reading: (optional uint),
    verification-threshold: uint
  }
)

(define-map sensor-readings
  {sensor-id: uint, timestamp: uint}
  {
    co2-reduction: uint,
    energy-generated: uint,
    trees-planted: uint,
    verified: bool,
    oracle: principal
  }
)

(define-map authorized-oracles
  principal
  bool
)

;; Private Functions
(define-private (is-valid-amount (amount uint))
  (> amount u0)
)

(define-private (is-valid-price (price uint))
  (> price u0)
)

(define-private (is-valid-string (input (string-ascii 50)))
  (and (> (len input) u0) (<= (len input) u50))
)

(define-private (is-valid-verification-standard (input (string-ascii 30)))
  (and (> (len input) u0) (<= (len input) u30))
)

(define-private (is-valid-sensor-address (input (string-ascii 100)))
  (and (> (len input) u0) (<= (len input) u100))
)

(define-private (is-valid-location (input (string-ascii 100)))
  (and (> (len input) u0) (<= (len input) u100))
)

(define-private (is-valid-sensor-type (input (string-ascii 30)))
  (and (> (len input) u0) (<= (len input) u30))
)

(define-private (is-valid-verification-status (input (string-ascii 20)))
  (and (> (len input) u0) (<= (len input) u20))
)

(define-private (is-authorized-oracle (oracle principal))
  (default-to false (map-get? authorized-oracles oracle))
)

(define-private (is-valid-principal (principal-to-check principal))
  ;; Check if principal is not the zero address equivalent
  ;; In Stacks, we can validate by checking it's not the contract caller in invalid states
  (not (is-eq principal-to-check 'ST000000000000000000002AMW42H))
)

(define-private (is-valid-sensor-id (sensor-id uint))
  (and (> sensor-id u0) (< sensor-id (var-get next-sensor-id)))
)

;; Enhanced sensor validation function that also checks existence
(define-private (validate-sensor-id-with-existence (sensor-id uint))
  (and 
    (is-valid-sensor-id sensor-id)
    (is-some (map-get? iot-sensors sensor-id))
  )
)

;; Safe arithmetic operations to prevent overflow
(define-private (safe-add (a uint) (b uint))
  (let ((result (+ a b)))
    (asserts! (>= result a) ERR_ARITHMETIC_OVERFLOW)
    (ok result)
  )
)

(define-private (safe-multiply (a uint) (b uint))
  (if (is-eq a u0)
    (ok u0)
    (let ((result (* a b)))
      (asserts! (is-eq (/ result a) b) ERR_ARITHMETIC_OVERFLOW)
      (ok result)
    )
  )
)

(define-private (update-user-balance (user principal) (credits uint) (retired uint))
  (let ((current-balance (default-to {total-credits: u0, total-retired: u0} (map-get? user-balances user))))
    (match (safe-add (get total-credits current-balance) credits)
      new-credits
        (match (safe-add (get total-retired current-balance) retired)
          new-retired
            (begin
              (map-set user-balances user {
                total-credits: new-credits,
                total-retired: new-retired
              })
              (ok true)
            )
          err-retired (err u115)
        )
      err-credits (err u115)
    )
  )
)

;; Batch operation helper functions
(define-private (validate-batch-size (batch-size uint))
  (and (> batch-size u0) (<= batch-size MAX_BATCH_SIZE))
)

;; Fixed process-single-credit-issuance with proper sensor validation
(define-private (process-single-credit-issuance 
  (credit-data {amount: uint, price: uint, project-type: (string-ascii 50), verification-standard: (string-ascii 30), sensor-id: (optional uint)})
  (acc {success: bool, total-amount: uint, credit-ids: (list 50 uint)}))
  (if (get success acc)
    (let (
      (amount (get amount credit-data))
      (price (get price credit-data))
      (project-type (get project-type credit-data))
      (verification-standard (get verification-standard credit-data))
      (sensor-id (get sensor-id credit-data))
      (credit-id (var-get next-credit-id))
    )
      (if (and 
            (is-valid-amount amount)
            (is-valid-price price)
            (is-valid-string project-type)
            (is-valid-verification-standard verification-standard))
        (match (safe-add (get total-amount acc) amount)
          new-total
            (begin
              ;; Properly validate and sanitize sensor-id
              (let ((final-sensor-id 
                (match sensor-id
                  some-sensor-id 
                    (if (validate-sensor-id-with-existence some-sensor-id)
                      (some some-sensor-id)
                      none)
                  none)))
                (map-set carbon-credits credit-id {
                  issuer: tx-sender,
                  owner: tx-sender,
                  amount: amount,
                  price-per-credit: price,
                  project-type: project-type,
                  verification-standard: verification-standard,
                  issue-date: stacks-block-height,
                  retired: false,
                  for-sale: false,
                  sensor-id: final-sensor-id,
                  verification-status: "pending",
                  last-verified: none
                }))
              (var-set next-credit-id (+ credit-id u1))
              {
                success: true,
                total-amount: new-total,
                credit-ids: (unwrap-panic (as-max-len? (append (get credit-ids acc) credit-id) u50))
              }
            )
          err-overflow {success: false, total-amount: (get total-amount acc), credit-ids: (get credit-ids acc)}
        )
        {success: false, total-amount: (get total-amount acc), credit-ids: (get credit-ids acc)}
      )
    )
    acc
  )
)

(define-private (process-single-credit-retirement 
  (credit-id uint)
  (acc {success: bool, total-retired: uint, retired-ids: (list 50 uint)}))
  (if (get success acc)
    (match (map-get? carbon-credits credit-id)
      credit 
        (if (and 
              (is-eq (get owner credit) tx-sender)
              (not (get retired credit)))
          (match (safe-add (get total-retired acc) (get amount credit))
            new-total
              (begin
                (map-set carbon-credits credit-id (merge credit {
                  retired: true,
                  for-sale: false
                }))
                (map-delete marketplace-listings credit-id)
                {
                  success: true,
                  total-retired: new-total,
                  retired-ids: (unwrap-panic (as-max-len? (append (get retired-ids acc) credit-id) u50))
                }
              )
            err-overflow {success: false, total-retired: (get total-retired acc), retired-ids: (get retired-ids acc)}
          )
          {success: false, total-retired: (get total-retired acc), retired-ids: (get retired-ids acc)}
        )
      {success: false, total-retired: (get total-retired acc), retired-ids: (get retired-ids acc)}
    )
    acc
  )
)

;; Public Functions

;; Issue new carbon credits with optional IoT sensor integration - Fixed validation
(define-public (issue-credits (amount uint) (price uint) (project-type (string-ascii 50)) (verification-standard (string-ascii 30)) (sensor-id (optional uint)))
  (let ((credit-id (var-get next-credit-id)))
    (asserts! (is-valid-amount amount) ERR_INVALID_AMOUNT)
    (asserts! (is-valid-price price) ERR_INVALID_PRICE)
    (asserts! (is-valid-string project-type) ERR_INVALID_STRING)
    (asserts! (is-valid-verification-standard verification-standard) ERR_INVALID_STRING)
    
    ;; Handle sensor validation with separate branches to avoid unchecked data
    (match sensor-id
      some-sensor-id 
        (begin
          (asserts! (validate-sensor-id-with-existence some-sensor-id) ERR_SENSOR_NOT_FOUND)
          (map-set carbon-credits credit-id {
            issuer: tx-sender,
            owner: tx-sender,
            amount: amount,
            price-per-credit: price,
            project-type: project-type,
            verification-standard: verification-standard,
            issue-date: stacks-block-height,
            retired: false,
            for-sale: false,
            sensor-id: (some some-sensor-id),
            verification-status: "pending",
            last-verified: none
          })
        )
      ;; No sensor case
      (map-set carbon-credits credit-id {
        issuer: tx-sender,
        owner: tx-sender,
        amount: amount,
        price-per-credit: price,
        project-type: project-type,
        verification-standard: verification-standard,
        issue-date: stacks-block-height,
        retired: false,
        for-sale: false,
        sensor-id: none,
        verification-status: "pending",
        last-verified: none
      })
    )
    
    (try! (update-user-balance tx-sender amount u0))
    (var-set next-credit-id (+ credit-id u1))
    (ok credit-id)
  )
)

;; Batch issue carbon credits with IoT integration
(define-public (batch-issue-credits 
  (credits-data (list 50 {amount: uint, price: uint, project-type: (string-ascii 50), verification-standard: (string-ascii 30), sensor-id: (optional uint)})))
  (let (
    (batch-size (len credits-data))
    (result (fold process-single-credit-issuance credits-data {success: true, total-amount: u0, credit-ids: (list)}))
  )
    (asserts! (validate-batch-size batch-size) ERR_EMPTY_BATCH)
    (asserts! (get success result) ERR_INVALID_AMOUNT)
    
    (try! (update-user-balance tx-sender (get total-amount result) u0))
    (ok {
      total-issued: batch-size,
      total-amount: (get total-amount result),
      credit-ids: (get credit-ids result)
    })
  )
)

;; Register IoT sensor for environmental monitoring
(define-public (register-iot-sensor 
  (sensor-address (string-ascii 100))
  (project-location (string-ascii 100))
  (sensor-type (string-ascii 30))
  (verification-threshold uint))
  (let ((sensor-id (var-get next-sensor-id)))
    (asserts! (is-valid-sensor-address sensor-address) ERR_INVALID_STRING)
    (asserts! (is-valid-location project-location) ERR_INVALID_STRING)
    (asserts! (is-valid-sensor-type sensor-type) ERR_INVALID_STRING)
    (asserts! (is-valid-amount verification-threshold) ERR_INVALID_AMOUNT)
    
    (map-set iot-sensors sensor-id {
      sensor-address: sensor-address,
      project-location: project-location,
      sensor-type: sensor-type,
      registered-by: tx-sender,
      registration-date: stacks-block-height,
      is-active: true,
      last-reading: none,
      verification-threshold: verification-threshold
    })
    
    (var-set next-sensor-id (+ sensor-id u1))
    (ok sensor-id)
  )
)

;; Private helper to validate and return a sensor ID or error
(define-private (validate-and-get-sensor-id (sensor-id uint))
  (if (validate-sensor-id-with-existence sensor-id)
    (ok sensor-id)
    ERR_SENSOR_NOT_FOUND
  )
)

;; Submit sensor reading (oracle only) - Enhanced validation
(define-public (submit-sensor-reading 
  (sensor-id uint) 
  (co2-reduction uint) 
  (energy-generated uint) 
  (trees-planted uint))
  (let (
    (validated-sensor-id (try! (validate-and-get-sensor-id sensor-id)))
    (current-block stacks-block-height)
  )
    ;; Validate oracle authorization first
    (asserts! (is-authorized-oracle tx-sender) ERR_INVALID_ORACLE)
    
    ;; Enhanced validation of sensor reading values
    (asserts! (and 
      (<= co2-reduction u340282366920938463463374607431768211455)
      (<= energy-generated u340282366920938463463374607431768211455)
      (<= trees-planted u340282366920938463463374607431768211455)
      (or (> co2-reduction u0) 
          (> energy-generated u0) 
          (> trees-planted u0))) 
      ERR_INVALID_SENSOR_DATA)
    
    ;; Get and validate sensor data
    (let (
      (sensor-data (unwrap! (map-get? iot-sensors validated-sensor-id) ERR_SENSOR_NOT_FOUND))
    )
      (asserts! (get is-active sensor-data) ERR_SENSOR_NOT_FOUND)
      
      ;; Store the sensor reading with validated data
      (map-set sensor-readings {sensor-id: validated-sensor-id, timestamp: current-block} {
        co2-reduction: co2-reduction,
        energy-generated: energy-generated,
        trees-planted: trees-planted,
        verified: true,
        oracle: tx-sender
      })
      
      ;; Update sensor's last reading
      (map-set iot-sensors validated-sensor-id (merge sensor-data {
        last-reading: (some current-block)
      }))
      
      (ok true)
    )
  )
)

;; Verify credits based on IoT sensor data
(define-public (verify-credits-with-sensor (credit-id uint))
  (let (
    (credit (unwrap! (map-get? carbon-credits credit-id) ERR_CREDIT_NOT_FOUND))
    (sensor-id-val (unwrap! (get sensor-id credit) ERR_SENSOR_NOT_FOUND))
  )
    (asserts! (is-eq tx-sender (get issuer credit)) ERR_UNAUTHORIZED)
    (asserts! (validate-sensor-id-with-existence sensor-id-val) ERR_SENSOR_NOT_FOUND)
    
    (let (
      (sensor-data (unwrap! (map-get? iot-sensors sensor-id-val) ERR_SENSOR_NOT_FOUND))
      (last-reading-block (unwrap! (get last-reading sensor-data) ERR_INVALID_SENSOR_DATA))
    )
      (match (map-get? sensor-readings {sensor-id: sensor-id-val, timestamp: last-reading-block})
        reading
          (let (
            (co2-val (get co2-reduction reading))
            (energy-val (get energy-generated reading))
            (trees-val (get trees-planted reading))
          )
            ;; Safe verification score calculation
            (match (safe-add co2-val energy-val)
              temp-sum
                (match (safe-add temp-sum trees-val)
                  verification-score
                    (begin
                      (asserts! (>= verification-score (get verification-threshold sensor-data)) ERR_VERIFICATION_THRESHOLD_NOT_MET)
                      
                      (map-set carbon-credits credit-id (merge credit {
                        verification-status: "verified",
                        last-verified: (some stacks-block-height)
                      }))
                      (ok true)
                    )
                  err-calc (err u115)
                )
              err-calc (err u115)
            )
          )
        (err u111)
      )
    )
  )
)

;; List credits for sale
(define-public (list-for-sale (credit-id uint) (price-per-credit uint))
  (let ((credit (unwrap! (map-get? carbon-credits credit-id) ERR_CREDIT_NOT_FOUND)))
    (asserts! (is-eq (get owner credit) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (not (get retired credit)) ERR_CREDIT_ALREADY_RETIRED)
    (asserts! (is-valid-price price-per-credit) ERR_INVALID_PRICE)
    
    (map-set carbon-credits credit-id (merge credit {
      for-sale: true,
      price-per-credit: price-per-credit
    }))
    
    (map-set marketplace-listings credit-id {
      seller: tx-sender,
      price-per-credit: price-per-credit,
      available-amount: (get amount credit),
      listing-date: stacks-block-height
    })
    
    (ok true)
  )
)

;; Purchase carbon credits with safe arithmetic
(define-public (purchase-credits (credit-id uint) (amount uint))
  (let (
    (credit (unwrap! (map-get? carbon-credits credit-id) ERR_CREDIT_NOT_FOUND))
    (listing (unwrap! (map-get? marketplace-listings credit-id) ERR_CREDIT_NOT_FOUND))
    (price-per-credit (get price-per-credit credit))
    (platform-fee-rate (var-get platform-fee))
  )
    (asserts! (get for-sale credit) ERR_CREDIT_NOT_FOUND)
    (asserts! (not (get retired credit)) ERR_CREDIT_ALREADY_RETIRED)
    (asserts! (not (is-eq tx-sender (get owner credit))) ERR_SELF_TRADE)
    (asserts! (is-valid-amount amount) ERR_INVALID_AMOUNT)
    (asserts! (<= amount (get available-amount listing)) ERR_INSUFFICIENT_BALANCE)
    
    ;; Safe calculation of costs
    (match (safe-multiply amount price-per-credit)
      total-cost
        (match (safe-multiply total-cost platform-fee-rate)
          fee-before-division
            (let (
              (fee (/ fee-before-division u10000))
              (seller-payment (- total-cost fee))
            )
              ;; Transfer STX from buyer to seller
              (try! (stx-transfer? seller-payment tx-sender (get seller listing)))
              
              ;; Transfer platform fee to contract owner
              (try! (stx-transfer? fee tx-sender CONTRACT_OWNER))
              
              ;; Update credit ownership
              (map-set carbon-credits credit-id (merge credit {
                owner: tx-sender,
                amount: amount,
                for-sale: false
              }))
              
              ;; Update balances safely
              (try! (update-user-balance tx-sender amount u0))
              (try! (update-user-balance (get seller listing) (- u0 amount) u0))
              
              ;; Remove from marketplace
              (map-delete marketplace-listings credit-id)
              
              (ok true)
            )
          err-fee-calc (err u115)
        )
      err-total-calc (err u115)
    )
  )
)

;; Retire carbon credits
(define-public (retire-credits (credit-id uint))
  (let ((credit (unwrap! (map-get? carbon-credits credit-id) ERR_CREDIT_NOT_FOUND)))
    (asserts! (is-eq (get owner credit) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (not (get retired credit)) ERR_CREDIT_ALREADY_RETIRED)
    
    (map-set carbon-credits credit-id (merge credit {
      retired: true,
      for-sale: false
    }))
    
    (try! (update-user-balance tx-sender (- u0 (get amount credit)) (get amount credit)))
    (map-delete marketplace-listings credit-id)
    (ok true)
  )
)

;; Batch retire carbon credits
(define-public (batch-retire-credits (credit-ids (list 50 uint)))
  (let (
    (batch-size (len credit-ids))
    (result (fold process-single-credit-retirement credit-ids {success: true, total-retired: u0, retired-ids: (list)}))
  )
    (asserts! (validate-batch-size batch-size) ERR_EMPTY_BATCH)
    (asserts! (get success result) ERR_UNAUTHORIZED)
    
    (try! (update-user-balance tx-sender (- u0 (get total-retired result)) (get total-retired result)))
    (ok {
      total-retired: batch-size,
      total-amount: (get total-retired result),
      retired-ids: (get retired-ids result)
    })
  )
)

;; Remove from sale
(define-public (remove-from-sale (credit-id uint))
  (let ((credit (unwrap! (map-get? carbon-credits credit-id) ERR_CREDIT_NOT_FOUND)))
    (asserts! (is-eq (get owner credit) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (get for-sale credit) ERR_CREDIT_NOT_FOUND)
    
    (map-set carbon-credits credit-id (merge credit {for-sale: false}))
    (map-delete marketplace-listings credit-id)
    (ok true)
  )
)

;; Admin functions (owner only)

;; Authorize oracle for sensor data submission - Enhanced validation
(define-public (authorize-oracle (oracle principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-valid-principal oracle) ERR_INVALID_PRINCIPAL)
    (asserts! (not (is-eq oracle tx-sender)) ERR_INVALID_PRINCIPAL) ;; Additional check
    (map-set authorized-oracles oracle true)
    (ok true)
  )
)

;; Revoke oracle authorization - Enhanced validation
(define-public (revoke-oracle (oracle principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-valid-principal oracle) ERR_INVALID_PRINCIPAL)
    (asserts! (default-to false (map-get? authorized-oracles oracle)) ERR_INVALID_ORACLE)
    (map-delete authorized-oracles oracle)
    (ok true)
  )
)

;; Update platform fee
(define-public (update-platform-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (<= new-fee u1000) ERR_INVALID_AMOUNT) ;; Max 10% fee
    (var-set platform-fee new-fee)
    (ok true)
  )
)

;; Deactivate sensor - Enhanced validation
(define-public (deactivate-sensor (sensor-id uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (validate-sensor-id-with-existence sensor-id) ERR_SENSOR_NOT_FOUND)
    
    (let ((sensor-data (unwrap! (map-get? iot-sensors sensor-id) ERR_SENSOR_NOT_FOUND)))
      (asserts! (get is-active sensor-data) ERR_SENSOR_NOT_FOUND)
      (map-set iot-sensors sensor-id (merge sensor-data {is-active: false}))
      (ok true)
    )
  )
)

;; Read-only functions

;; Get credit details
(define-read-only (get-credit-details (credit-id uint))
  (map-get? carbon-credits credit-id)
)

;; Get user balance
(define-read-only (get-user-balance (user principal))
  (default-to {total-credits: u0, total-retired: u0} (map-get? user-balances user))
)

;; Get marketplace listing
(define-read-only (get-marketplace-listing (credit-id uint))
  (map-get? marketplace-listings credit-id)
)

;; Get IoT sensor details
(define-read-only (get-sensor-details (sensor-id uint))
  (map-get? iot-sensors sensor-id)
)

;; Get sensor reading
(define-read-only (get-sensor-reading (sensor-id uint) (timestamp uint))
  (map-get? sensor-readings {sensor-id: sensor-id, timestamp: timestamp})
)

;; Check if oracle is authorized
(define-read-only (is-oracle-authorized (oracle principal))
  (is-authorized-oracle oracle)
)

;; Get platform fee
(define-read-only (get-platform-fee)
  (var-get platform-fee)
)

;; Get next credit ID
(define-read-only (get-next-credit-id)
  (var-get next-credit-id)
)

;; Get next sensor ID
(define-read-only (get-next-sensor-id)
  (var-get next-sensor-id)
)

;; Get maximum batch size
(define-read-only (get-max-batch-size)
  MAX_BATCH_SIZE
)

;; Check if credit is available for purchase
(define-read-only (is-credit-available (credit-id uint))
  (match (map-get? carbon-credits credit-id)
    credit (and (get for-sale credit) (not (get retired credit)))
    false
  )
)

;; Check if credit is IoT verified
(define-read-only (is-credit-verified (credit-id uint))
  (match (map-get? carbon-credits credit-id)
    credit 
      (let ((status (get verification-status credit)))
        (is-eq status "verified")
      )
    false
  )
)