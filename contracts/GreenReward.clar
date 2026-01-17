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
(define-constant ERR_INVALID_FRACTION (err u117))
(define-constant ERR_CREDIT_CANNOT_BE_SPLIT (err u118))
(define-constant ERR_SELF_TRANSFER (err u119))
(define-constant ERR_CREDIT_LISTED_FOR_SALE (err u120))
(define-constant MAX_BATCH_SIZE u50)
(define-constant MIN_FRACTION_AMOUNT u1)

;; Data Variables
(define-data-var next-credit-id uint u1)
(define-data-var next-sensor-id uint u1)
(define-data-var platform-fee uint u250)
(define-data-var next-transfer-id uint u1)

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
    last-verified: (optional uint),
    parent-credit-id: (optional uint),
    is-fractional: bool
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

(define-map credit-fractions
  uint
  {
    original-credit-id: uint,
    fraction-number: uint,
    total-fractions: uint
  }
)

(define-map credit-transfers
  uint
  {
    from: principal,
    to: principal,
    credit-id: uint,
    amount: uint,
    transfer-date: uint
  }
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
  (not (is-eq principal-to-check 'ST000000000000000000002AMW42H))
)

(define-private (is-valid-sensor-id (sensor-id uint))
  (and (> sensor-id u0) (< sensor-id (var-get next-sensor-id)))
)

(define-private (validate-sensor-id-with-existence (sensor-id uint))
  (and 
    (is-valid-sensor-id sensor-id)
    (is-some (map-get? iot-sensors sensor-id))
  )
)

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

(define-private (safe-subtract (a uint) (b uint))
  (if (>= a b)
    (ok (- a b))
    ERR_INVALID_AMOUNT
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

(define-private (validate-batch-size (batch-size uint))
  (and (> batch-size u0) (<= batch-size MAX_BATCH_SIZE))
)

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
                  last-verified: none,
                  parent-credit-id: none,
                  is-fractional: false
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

(define-private (generate-fraction-indices (count uint))
  (if (<= count u10)
    (if (<= count u5)
      (if (<= count u2) (list u1 u2)
      (if (is-eq count u3) (list u1 u2 u3)
      (if (is-eq count u4) (list u1 u2 u3 u4)
      (list u1 u2 u3 u4 u5))))
      (if (<= count u7)
        (if (is-eq count u6) (list u1 u2 u3 u4 u5 u6)
        (list u1 u2 u3 u4 u5 u6 u7))
        (if (is-eq count u8) (list u1 u2 u3 u4 u5 u6 u7 u8)
        (if (is-eq count u9) (list u1 u2 u3 u4 u5 u6 u7 u8 u9)
        (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10)))))
    (if (<= count u20)
      (if (<= count u15)
        (if (is-eq count u11) (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11)
        (if (is-eq count u12) (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12)
        (if (is-eq count u13) (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13)
        (if (is-eq count u14) (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14)
        (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15)))))
        (if (is-eq count u16) (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16)
        (if (is-eq count u17) (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17)
        (if (is-eq count u18) (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18)
        (if (is-eq count u19) (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19)
        (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20))))))
      (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50)))
)

(define-private (process-fraction-creation 
  (fraction-index uint)
  (state {
    credit: {
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
      last-verified: (optional uint),
      parent-credit-id: (optional uint),
      is-fractional: bool
    },
    credit-id: uint,
    base-amount: uint,
    remainder: uint,
    total-fractions: uint,
    ids: (list 50 uint)
  }))
  (let (
    (credit (get credit state))
    (credit-id (get credit-id state))
    (base-amount (get base-amount state))
    (remainder (get remainder state))
    (total-fractions (get total-fractions state))
    (fraction-amount (if (is-eq fraction-index u1)
      (+ base-amount remainder)
      base-amount))
    (new-credit-id (var-get next-credit-id))
  )
    (if (<= fraction-index total-fractions)
      (begin
        (map-set carbon-credits new-credit-id {
          issuer: (get issuer credit),
          owner: (get owner credit),
          amount: fraction-amount,
          price-per-credit: (get price-per-credit credit),
          project-type: (get project-type credit),
          verification-standard: (get verification-standard credit),
          issue-date: (get issue-date credit),
          retired: false,
          for-sale: false,
          sensor-id: (get sensor-id credit),
          verification-status: (get verification-status credit),
          last-verified: (get last-verified credit),
          parent-credit-id: (some credit-id),
          is-fractional: true
        })
        (map-set credit-fractions new-credit-id {
          original-credit-id: credit-id,
          fraction-number: fraction-index,
          total-fractions: total-fractions
        })
        (var-set next-credit-id (+ new-credit-id u1))
        {
          credit: credit,
          credit-id: credit-id,
          base-amount: base-amount,
          remainder: remainder,
          total-fractions: total-fractions,
          ids: (unwrap-panic (as-max-len? (append (get ids state) new-credit-id) u50))
        }
      )
      state
    )
  )
)

(define-private (validate-fractions-for-merge (fraction-ids (list 50 uint)))
  (let ((first-id (unwrap! (element-at? fraction-ids u0) ERR_INVALID_AMOUNT)))
    (let ((first-fraction (unwrap! (map-get? carbon-credits first-id) ERR_CREDIT_NOT_FOUND)))
      (asserts! (get is-fractional first-fraction) ERR_INVALID_FRACTION)
      (asserts! (is-eq (get owner first-fraction) tx-sender) ERR_UNAUTHORIZED)
      (asserts! (not (get retired first-fraction)) ERR_CREDIT_ALREADY_RETIRED)
      (asserts! (not (get for-sale first-fraction)) ERR_CREDIT_CANNOT_BE_SPLIT)
      (ok true)
    )
  )
)

(define-private (sum-fraction-amounts (fraction-id uint) (state {total: uint, valid: bool}))
  (if (get valid state)
    (match (map-get? carbon-credits fraction-id)
      credit
        {
          total: (+ (get total state) (get amount credit)),
          valid: true
        }
      {total: (get total state), valid: false}
    )
    state
  )
)

(define-private (retire-fractions-helper (fraction-ids (list 50 uint)))
  (fold retire-single-fraction fraction-ids (ok true))
)

(define-private (retire-single-fraction (fraction-id uint) (acc (response bool uint)))
  (match acc
    success
      (match (map-get? carbon-credits fraction-id)
        credit
          (begin
            (map-set carbon-credits fraction-id (merge credit {
              retired: true,
              for-sale: false
            }))
            (map-delete marketplace-listings fraction-id)
            (ok true)
          )
        ERR_CREDIT_NOT_FOUND
      )
    error acc
  )
)

;; Public Functions

(define-public (issue-credits (amount uint) (price uint) (project-type (string-ascii 50)) (verification-standard (string-ascii 30)) (sensor-id (optional uint)))
  (let ((credit-id (var-get next-credit-id)))
    (asserts! (is-valid-amount amount) ERR_INVALID_AMOUNT)
    (asserts! (is-valid-price price) ERR_INVALID_PRICE)
    (asserts! (is-valid-string project-type) ERR_INVALID_STRING)
    (asserts! (is-valid-verification-standard verification-standard) ERR_INVALID_STRING)
    
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
            last-verified: none,
            parent-credit-id: none,
            is-fractional: false
          })
        )
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
        last-verified: none,
        parent-credit-id: none,
        is-fractional: false
      })
    )
    
    (try! (update-user-balance tx-sender amount u0))
    (var-set next-credit-id (+ credit-id u1))
    (ok credit-id)
  )
)

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

(define-public (fractionalize-credit (credit-id uint) (number-of-fractions uint))
  (let (
    (credit (unwrap! (map-get? carbon-credits credit-id) ERR_CREDIT_NOT_FOUND))
    (total-amount (get amount credit))
  )
    (asserts! (is-eq (get owner credit) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (not (get retired credit)) ERR_CREDIT_ALREADY_RETIRED)
    (asserts! (not (get for-sale credit)) ERR_CREDIT_CANNOT_BE_SPLIT)
    (asserts! (not (get is-fractional credit)) ERR_CREDIT_CANNOT_BE_SPLIT)
    (asserts! (and (>= number-of-fractions u2) (<= number-of-fractions u50)) ERR_INVALID_FRACTION)
    (asserts! (>= total-amount number-of-fractions) ERR_INVALID_AMOUNT)
    
    (let (
      (base-fraction-amount (/ total-amount number-of-fractions))
      (remainder (mod total-amount number-of-fractions))
    )
      (asserts! (>= base-fraction-amount MIN_FRACTION_AMOUNT) ERR_INVALID_FRACTION)
      
      (let (
        (fraction-indices (generate-fraction-indices number-of-fractions))
        (result (fold process-fraction-creation fraction-indices {
          credit: credit,
          credit-id: credit-id,
          base-amount: base-fraction-amount,
          remainder: remainder,
          total-fractions: number-of-fractions,
          ids: (list)
        }))
      )
        (map-set carbon-credits credit-id (merge credit {
          retired: true,
          for-sale: false
        }))
        
        (ok {
          original-credit-id: credit-id,
          fraction-ids: (get ids result),
          total-fractions: number-of-fractions
        })
      )
    )
  )
)

(define-public (merge-fractional-credits (fraction-ids (list 50 uint)))
  (let (
    (batch-size (len fraction-ids))
    (validated-fractions (try! (validate-fractions-for-merge fraction-ids)))
  )
    (asserts! (validate-batch-size batch-size) ERR_EMPTY_BATCH)
    (asserts! (>= batch-size u2) ERR_INVALID_AMOUNT)
    
    (let (
      (first-fraction (unwrap-panic (map-get? carbon-credits (unwrap-panic (element-at? fraction-ids u0)))))
      (total-result (fold sum-fraction-amounts fraction-ids {total: u0, valid: true}))
      (merged-credit-id (var-get next-credit-id))
    )
      (asserts! (get valid total-result) ERR_CREDIT_NOT_FOUND)
      
      (map-set carbon-credits merged-credit-id {
        issuer: (get issuer first-fraction),
        owner: tx-sender,
        amount: (get total total-result),
        price-per-credit: (get price-per-credit first-fraction),
        project-type: (get project-type first-fraction),
        verification-standard: (get verification-standard first-fraction),
        issue-date: (get issue-date first-fraction),
        retired: false,
        for-sale: false,
        sensor-id: (get sensor-id first-fraction),
        verification-status: (get verification-status first-fraction),
        last-verified: (get last-verified first-fraction),
        parent-credit-id: (get parent-credit-id first-fraction),
        is-fractional: false
      })
      
      (try! (retire-fractions-helper fraction-ids))
      
      (var-set next-credit-id (+ merged-credit-id u1))
      (ok merged-credit-id)
    )
  )
)

(define-public (transfer-credit (credit-id uint) (recipient principal))
  (let (
    (credit (unwrap! (map-get? carbon-credits credit-id) ERR_CREDIT_NOT_FOUND))
    (transfer-id (var-get next-transfer-id))
  )
    (asserts! (is-eq (get owner credit) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (not (get retired credit)) ERR_CREDIT_ALREADY_RETIRED)
    (asserts! (not (get for-sale credit)) ERR_CREDIT_LISTED_FOR_SALE)
    (asserts! (is-valid-principal recipient) ERR_INVALID_PRINCIPAL)
    (asserts! (not (is-eq tx-sender recipient)) ERR_SELF_TRANSFER)
    
    (map-set carbon-credits credit-id (merge credit {
      owner: recipient
    }))
    
    (map-set credit-transfers transfer-id {
      from: tx-sender,
      to: recipient,
      credit-id: credit-id,
      amount: (get amount credit),
      transfer-date: stacks-block-height
    })
    
    (var-set next-transfer-id (+ transfer-id u1))
    
    (match (safe-subtract u0 (get amount credit))
      neg-amount
        (begin
          (try! (update-user-balance tx-sender neg-amount u0))
          (try! (update-user-balance recipient (get amount credit) u0))
          (ok transfer-id)
        )
      err-subtract
        (begin
          (try! (update-user-balance tx-sender u0 u0))
          (try! (update-user-balance recipient (get amount credit) u0))
          (ok transfer-id)
        )
    )
  )
)

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

(define-private (validate-and-get-sensor-id (sensor-id uint))
  (if (validate-sensor-id-with-existence sensor-id)
    (ok sensor-id)
    ERR_SENSOR_NOT_FOUND
  )
)
(define-public (submit-sensor-reading 
  (sensor-id uint)
  (co2-reduction uint)
  (energy-generated uint)
  (trees-planted uint)
  (oracle principal))
  (let ((validated-sensor-id (try! (validate-and-get-sensor-id sensor-id))))
    (asserts! (is-authorized-oracle oracle) ERR_INVALID_ORACLE)
    (asserts! (is-valid-amount co2-reduction) ERR_INVALID_SENSOR_DATA)
    (asserts! (is-valid-amount energy-generated) ERR_INVALID_SENSOR_DATA)
    (asserts! (is-valid-amount trees-planted) ERR_INVALID_SENSOR_DATA)
    
    (map-set sensor-readings {sensor-id: validated-sensor-id, timestamp: stacks-block-height} {
      co2-reduction: co2-reduction,
      energy-generated: energy-generated,
      trees-planted: trees-planted,
      verified: false,
      oracle: oracle
    })
    
    (ok true)
  )
)