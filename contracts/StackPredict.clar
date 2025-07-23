;; StackPredict Smart Contract
;; Prediction market for various outcomes

;; ----------------------------------------
;; DATA MAPS AND VARIABLES
;; ----------------------------------------

;; Market counter to generate unique IDs
(define-data-var market-counter uint u0)

;; Markets map - stores all prediction markets
(define-map markets
  { market-id: uint }
  {
    creator: principal,
    question: (string-ascii 100),
    options: (list 10 (string-ascii 50)),
    deadline: uint,
    resolved: bool,
    winning-option: (optional (string-ascii 50))  ;; Properly defined as optional type
  }
)

;; Bets map - stores user bets for each market
(define-map bets
  { market-id: uint, user: principal }
  {
    option: (string-ascii 50),
    amount: uint
  }
)

;; ----------------------------------------
;; CREATE MARKET
;; ----------------------------------------

(define-public (create-market 
  (question (string-ascii 100)) 
  (options (list 10 (string-ascii 50))) 
  (deadline uint)
)
  (begin
    (let (
      (id (var-get market-counter))
    )
      (map-set markets
        { market-id: id }  ;; Fixed: use proper map key format
        {
          creator: tx-sender,
          question: question,
          options: options,
          deadline: deadline,
          resolved: false,
          winning-option: none  ;; Now correctly matches the optional type
        }
      )
      (var-set market-counter (+ id u1))
      (ok id)
    )
  )
)

;; ----------------------------------------
;; PLACE A BET
;; ----------------------------------------

(define-public (place-bet (market-id uint) (option (string-ascii 50)) (amount uint))
  (begin
    (match (map-get? markets { market-id: market-id })  ;; Fixed: consistent key format
      market
      (if (is-eq false (get resolved market))
        (if (< stacks-block-height (get deadline market))
          (if (>= amount u10000000) ;; Require minimum bet amount: 10 STX
            (let (
              (transfer-result (stx-transfer? amount tx-sender (as-contract tx-sender)))
            )
              (if (is-ok transfer-result)
                (begin
                  (map-set bets 
                    { market-id: market-id, user: tx-sender } 
                    { option: option, amount: amount })
                  (ok true)
                )
                (err u110) ;; Transfer failed
              )
            )
            (err u111) ;; Amount too low
          )
          (err u101) ;; Deadline passed
        )
        (err u102) ;; Market already resolved
      )
      (err u103) ;; Market not found
    )
  )
)

;; ----------------------------------------
;; RESOLVE MARKET
;; ----------------------------------------

(define-public (resolve-market (market-id uint) (winning (string-ascii 50)))
  (begin
    (match (map-get? markets { market-id: market-id })  ;; Fixed: consistent key format
      market
      (if (is-eq tx-sender (get creator market))
        (if (is-eq false (get resolved market))
          (begin
            (map-set markets 
              { market-id: market-id }  ;; Fixed: consistent key format
              (merge market {
                resolved: true,
                winning-option: (some winning)
              })
            )
            (ok true)
          )
          (err u104) ;; Already resolved
        )
        (err u105) ;; Not creator
      )
      (err u103) ;; Market not found
    )
  )
)

;; ----------------------------------------
;; CLAIM WINNINGS
;; ----------------------------------------

(define-public (claim-winnings (market-id uint))
  (begin
    (match (map-get? markets { market-id: market-id })  ;; Fixed: consistent key format
      market
      (if (is-eq true (get resolved market))
        (match (get winning-option market)
          some-winning
          (match (map-get? bets {market-id: market-id, user: tx-sender})
            user-bet
            (if (is-eq (get option user-bet) some-winning)
              ;; Payout if prediction is correct
              (stx-transfer? 
                (* u2 (get amount user-bet)) 
                (as-contract tx-sender) 
                tx-sender)
              (err u106) ;; You lost the bet
            )
            (err u107) ;; No bet found
          )
          (err u108) ;; No winning option
        )
        (err u109) ;; Market not resolved yet
      )
      (err u103) ;; Market not found
    )
  )
)

;; ----------------------------------------
;; READ-ONLY FUNCTIONS
;; ----------------------------------------

(define-read-only (get-market (market-id uint))
  (map-get? markets { market-id: market-id })
)

(define-read-only (get-bet (market-id uint) (user principal))
  (map-get? bets { market-id: market-id, user: user })
)

(define-read-only (get-market-count)
  (var-get market-counter)
)