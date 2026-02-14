use bank_db;

select count(*) from bank_accounts;
select count(*) from bank_branches;
select count(*) from bank_customers;
select count(*) from bank_loans;
select count(*) from bank_repayments;
select count(*) from bank_transactions;

select * from bank_accounts;
select * from bank_branches;
select * from bank_customers;
select * from bank_loans;
select * from bank_repayments;
select * from bank_transactions;

create view acc_status as 
select account_status, count(*) from bank_accounts group by 1;

select * from acc_status;

select * from bank_accounts;

create view acc_type as select account_type, count(*) as Count from bank_accounts group by 1;
select * from acc_type;

create view balance as
select customer_id, current_balance from bank_accounts order by 2;

select * from balance;

create view Branches_in_City as
select city, count(*) as total_branches_in_city from bank_branches group by 1;

select * from bank_customers;

create view Top_10_Income_Customers as
select customer_name, income from bank_customers order by 2 desc limit 10;

create view City_wise_Customer_Count as
select city, count(*) as Customer_Count from bank_customers group by 1;

create view T10_Cust_by_LoanAmount as
select customer_id, loan_amount from bank_loans order by 2 desc limit 10;

select * from bank_accounts;
select * from bank_transactions;

create view cust_lifetime_value as
select a.customer_id, c.customer_name, sum(t.amount) as Total_Transaction_Amount, avg(t.amount) as Avg_balance 
from bank_accounts as a join bank_customers as c on a.customer_id = c.customer_id
join bank_transactions as t on a.account_id = t.account_id
group by 1,2
order by 4 desc;

select customer_id, avg(current_balance) as Avg_Balance from bank_accounts group by 1 order by 2 desc;

create view inactive_cust as
select 
	c.customer_id, 
    c.customer_name, 
	max(t.transaction_date) as last_transaction_date, 
	datediff(curdate(), max(t.transaction_date)) as inactive_days
from bank_customers as c join bank_accounts as a on c.customer_id = a.customer_id
join bank_transactions as t on a.account_id = t.account_id
group by 1,2
having inactive_days >= 180
order by 4 desc;

create view monthly_transaction_summary as
select 
	date_format(transaction_date, '%Y-%m') as month,
    transaction_type,
    sum(amount) as total_amount,
    count(*) as transaction_count
from bank_transactions group by 1,2 order by 1,2;

create view Daily_Transaction_Summary as
select 
	date(transaction_date) as Transaction_Date,
	avg(amount) as avg_transaction_value,
    count(*) as Transaction_Count
from bank_transactions
group by date(transaction_date);

create view Branch_wise_Total_Balance as
select
	b.branch_name,
    b.city,
    sum(a.current_balance) as Total_Balance
from bank_branches as b join bank_accounts as a on b.branch_id = a.branch_id
group by 1,2;

create view Branch_wise_Cust_Count as
select
	b.branch_name,
    count(distinct a.customer_id) as Cust_Count
from bank_branches as b
join bank_accounts as a on b.branch_id = a.branch_id
group by 1;

create view low_balance_accounts as
select 
	account_id, 
	customer_id, 
    current_balance 
from bank_accounts 
where current_balance<10000;

create view Dormant_Acc as
select
	a.account_id,
    a.customer_id
from bank_accounts as a 
left join bank_transactions as t on a.account_id = t.account_id
where t.account_id is null;

create view Income_Balance_Transaction_Summary as
select 
	c.customer_id,
    c.income,
    avg(a.current_balance) as avg_balance,
    count(t.transaction_id) as transaction_count
from bank_customers as c
join bank_accounts as a on c.customer_id = a.customer_id
left join bank_transactions as t on a.account_id = t.account_id
group by 1,2;

create view loan_repayment_status as
select
    l.loan_id,
    l.customer_id,
    l.loan_amount,
    ifnull(sum(case
        when lower(r.payment_status) = 'paid'
        then r.emi_amount
        else 0
    end), 0) as total_paid,
    greatest(
        l.loan_amount - ifnull(sum(case
            when lower(r.payment_status) = 'paid'
            then r.emi_amount
            else 0
        end), 0),
        0
    ) as outstanding_amount,
    case
        when ifnull(sum(case
            when lower(r.payment_status) = 'paid'
            then r.emi_amount
            else 0
        end), 0) >= l.loan_amount
        then 'fully paid'
        else 'pending'
    end as repayment_status

from bank_loans l
left join bank_repayments r
    on l.loan_id = r.loan_id
group by 1,2,3;

create view loan_late_repayments_summary as
select
    r.repayment_id,
    r.loan_id,
    l.customer_id,
    r.payment_date,
    r.emi_amount,
    r.payment_status,
    case
		when lower(r.payment_status) = 'missed' then 'high risk'
		when lower(r.payment_status) = 'delayed' then 'medium risk'
	end as risk_flag
from bank_repayments r
join bank_loans l
    on r.loan_id = l.loan_id
where r.payment_status in ('Delayed','Missed');

select repayment_status, count(*) as count from loan_repayment_status group by 1 order by 2 desc;
select * from loan_late_repayments_summary;
select * from loan_repayment_status;

select payment_status, count(*) as count from loan_late_repayments_summary group by 1 order by 2;
select risk_flag, count(*) as count from loan_late_repayments_summary group by 1 order by 2;

create view customer_delinquency_summary as
select
    l.customer_id,
    sum(case when lower(r.payment_status) = 'paid' then 1 else 0 end) as paid_emis,
    sum(case when lower(r.payment_status) = 'delayed' then 1 else 0 end) as delayed_emis,
    sum(case when lower(r.payment_status) = 'missed' then 1 else 0 end) as missed_emis,
    count(r.repayment_id) as total_emis,
    case
        when sum(case when lower(r.payment_status) = 'missed' then 1 else 0 end) >= 2
            then 'high risk'
        when sum(case when lower(r.payment_status) = 'delayed' then 1 else 0 end) >= 1
            then 'medium risk'
        else 'low risk'
    end as risk_category
from bank_repayments as r
join bank_loans as l
    on r.loan_id = l.loan_id
group by l.customer_id;

create view loan_delinquency_summary as
select
    r.loan_id,
    count(*) as total_emis,
    sum(case when lower(r.payment_status) = 'paid' then 1 else 0 end) as paid_emis,
    sum(case when lower(r.payment_status) = 'delayed' then 1 else 0 end) as delayed_emis,
    sum(case when lower(r.payment_status) = 'missed' then 1 else 0 end) as missed_emis,
    case
        when sum(case when lower(r.payment_status) = 'missed' then 1 else 0 end) >= 2
            then 'high risk'
        when sum(case when lower(r.payment_status) = 'delayed' then 1 else 0 end) >= 1
            then 'medium risk'
        else 'healthy'
    end as loan_health
from bank_repayments as r group by 1;

create view branch_loan_exposure as
select
    b.branch_name,
    b.region,
    sum(l.loan_amount) as total_loan_amount,
    count(l.loan_id) as total_loans
from bank_loans as l
join bank_accounts as a
    on l.customer_id = a.customer_id
join bank_branches as b
    on a.branch_id = b.branch_id
group by 1,2 order by 4 desc;

create view region_wise_loan_exposure as
select
    b.region,
    sum(distinct l.loan_amount) as total_loan_amount,
    count(distinct l.loan_id) as total_loans
from bank_loans l
join bank_accounts as a
    on l.customer_id = a.customer_id
join bank_branches as b
    on a.branch_id = b.branch_id
group by 1 order by 3 desc;

create view region_wise_credit_risk as
select
    b.region,
    sum(distinct l.loan_amount) as total_loan_amount,
    count(distinct l.loan_id) as total_loans,
    sum(case when r.payment_status = 'Missed' then 1 else 0 end) as missed_emis,
    sum(case when r.payment_status = 'Delayed' then 1 else 0 end) as delayed_emis
from bank_loans l
join bank_accounts as a
    on l.customer_id = a.customer_id
join bank_branches as b
    on a.branch_id = b.branch_id
left join bank_repayments as r
    on l.loan_id = r.loan_id
group by 1 order by 3 desc;

create view branch_wise_credit_risk as
select
    b.branch_name,
    b.region,
    sum(distinct l.loan_amount) as total_loan_amount,
    count(distinct l.loan_id) as total_loans,
    sum(case when r.payment_status = 'Missed' then 1 else 0 end) as missed_emis,
    sum(case when r.payment_status = 'Delayed' then 1 else 0 end) as delayed_emis
from bank_loans l
join bank_accounts as a
    on l.customer_id = a.customer_id
join bank_branches as b
    on a.branch_id = b.branch_id
left join bank_repayments as r
    on l.loan_id = r.loan_id
group by 1,2 order by 3 desc;

create view customer_lifecycle_value as
select
    c.customer_id,
    round(datediff(curdate(), c.customer_since) / 365, 1) as customer_years,
    ifnull(sum(t.amount), 0) as total_transaction_value,
    count(distinct l.loan_id) as total_loan_count,
    ifnull(sum(distinct l.loan_amount), 0) as total_loan_amount
from bank_customers c
left join bank_accounts as a
    on c.customer_id = a.customer_id
left join bank_transactions as t
    on a.account_id = t.account_id
left join bank_loans as l
    on c.customer_id = l.customer_id
group by c.customer_id, c.customer_since order by 2 desc;

create view active_vs_inactive_loan_customers as
select
    case
        when l.customer_id is null then 'no loans'
        when l.loan_status = 'active' then 'active loan'
        else 'closed loan'
    end as loan_category,
    count(distinct c.customer_id) as customer_count
from bank_customers c
left join bank_loans l
    on c.customer_id = l.customer_id
group by 1;

create view loan_customers_with_no_transactions as
select
    l.customer_id,
    count(distinct l.loan_id) as loan_count
from bank_loans l
left join bank_accounts a
    on l.customer_id = a.customer_id
left join bank_transactions t
    on a.account_id = t.account_id
where t.transaction_id is null group by 1;

create view avg_emi_vs_income as
select
    c.customer_id,
    c.income,
    round(avg(r.emi_amount), 0) as avg_emi,
    round((avg(r.emi_amount) / c.income) * 100, 2) as income_spent_on_emi_pct
from bank_customers c
join bank_loans l
    on c.customer_id = l.customer_id
join bank_repayments r
    on l.loan_id = r.loan_id
where r.payment_status = 'Paid'
group by 1,2;

create view loan_closure_rate as
select
    count(case when loan_status = 'closed' then 1 end) as closed_loans,
    count(*) as total_loans,
    round(count(case when loan_status = 'closed' then 1 end) / count(*) * 100, 2) as closure_rate_pct
from bank_loans;

use bank_db;
select repayment_status, count(*) from loan_repayment_status group by 1;

create view active_accounts as
select * from bank_accounts where account_status = "Active";

use bank_db;
select * from bank_branches;
select * from bank_loans;
select * from bank_repayments;

create view outstanding_amt_by_branch as
select
    br.branch_id,
    br.branch_name,
    sum(l.loan_amount)
      - ifnull(sum(case
            when r.payment_status = 'Paid'
            then r.emi_amount
            else 0
        end), 0) as outstanding_loan_amount
from bank_branches as br join bank_accounts as a on br.branch_id = a.branch_id
join bank_loans as l on a.customer_id = l.customer_id
left join bank_repayments as r on l.loan_id = r.loan_id
group by 1,2
order by 3 desc;

create view outstanding_loan_amt_by_region as
select
    br.region,
    sum(l.loan_amount)
      - ifnull(sum(case
            when r.payment_status = 'Paid'
            then r.emi_amount
            else 0
        end), 0) as outstanding_loan_amount
from bank_branches as br join bank_accounts as a on br.branch_id = a.branch_id
join bank_loans as l on a.customer_id = l.customer_id
left join bank_repayments as r on l.loan_id = r.loan_id
group by 1
order by 2 desc;

select * from outstanding_loan_amt_by_region;

use bank_db;
drop view loan_delayed_repayments_summary;
create view loan_delayed_repayments_summary as
select
    r.repayment_id,
    r.loan_id,
    l.customer_id,
    r.payment_date,
    r.emi_amount,
    r.payment_status
from bank_repayments as r
join bank_loans as l on r.loan_id = l.loan_id
where r.payment_status = 'Delayed';

select * from loan_delayed_repayments_summary;

use bank_db;
create view customer_loan_summary as
select
    l.customer_id,
    count(distinct l.loan_id) as loan_count,
    sum(
        case
            when ifnull(r.total_paid, 0) < l.loan_amount
            then 1
            else 0
        end
    ) as pending_loan_count,
    sum(
        l.loan_amount - ifnull(r.total_paid, 0)
    ) as total_outstanding from bank_loans as l
left join (
    select
        loan_id,
        sum(
            case
                when lower(payment_status) = 'paid'
                then emi_amount
                else 0
            end
        ) as total_paid
    from bank_repayments
    group by 1
) r
on l.loan_id = r.loan_id
group by 1;

create view customer_loan_summary_bucket as
select
    *,
    case
        when loan_count = 1 then '1 loan'
        when loan_count between 2 and 3 then '2-3 loans'
        else '4+ loans'
    end as loan_count_bucket
from customer_loan_summary;

create view customer_loan_summary_bucket_risk as
select
    *,
    case
        when pending_loan_count > 1 then 'high risk'
        when pending_loan_count = 1 then 'medium risk'
        else 'healthy'
    end as customer_risk
from customer_loan_summary_bucket;