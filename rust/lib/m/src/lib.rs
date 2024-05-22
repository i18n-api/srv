#[allow(non_snake_case,clippy::too_many_arguments)]
mod r#fn {
  pub use mysql_macro::*;

pub async fn authArchId(v:impl AsRef<str>)->Result<u32>{
  Ok(q1!("SELECT authArchId(?)",v.as_ref()))
}

#[macro_export]
macro_rules! authArchId {
($v:expr) => {
$crate::authArchId($v).await?
};
}

pub async fn authBrowserId(v:impl AsRef<str>)->Result<u32>{
  Ok(q1!("SELECT authBrowserId(?)",v.as_ref()))
}

#[macro_export]
macro_rules! authBrowserId {
($v:expr) => {
$crate::authBrowserId($v).await?
};
}

pub async fn authBrowserVerId(browser:impl AsRef<str>,major:u16,minor:u16)->Result<u64>{
let sql = format!("SELECT authBrowserVerId(?,{major},{minor})");
  Ok(q1!(sql,browser.as_ref()))
}

#[macro_export]
macro_rules! authBrowserVerId {
($browser:expr,$major:expr,$minor:expr) => {
$crate::authBrowserVerId($browser,$major,$minor).await?
};
}

pub async fn authGpuId(v:impl AsRef<str>)->Result<u32>{
  Ok(q1!("SELECT authGpuId(?)",v.as_ref()))
}

#[macro_export]
macro_rules! authGpuId {
($v:expr) => {
$crate::authGpuId($v).await?
};
}

pub async fn authHardwareId(w:u16,h:u16,pixelRatio:u8,cpu:u16,gpu:impl AsRef<str>,arch:impl AsRef<str>)->Result<u64>{
let sql = format!("SELECT authHardwareId({w},{h},{pixelRatio},{cpu},?,?)");
  Ok(q1!(sql,gpu.as_ref(),arch.as_ref()))
}

#[macro_export]
macro_rules! authHardwareId {
($w:expr,$h:expr,$pixelRatio:expr,$cpu:expr,$gpu:expr,$arch:expr) => {
$crate::authHardwareId($w,$h,$pixelRatio,$cpu,$gpu,$arch).await?
};
}

pub async fn authHostIdMailUid(hostId:u64,mail:impl AsRef<str>)->Result<Option<u64>>{
let sql = format!("SELECT authHostIdMailUid({hostId},?)");
  Ok(q1!(sql,mail.as_ref()))
}

#[macro_export]
macro_rules! authHostIdMailUid {
($hostId:expr,$mail:expr) => {
$crate::authHostIdMailUid($hostId,$mail).await?
};
}

pub async fn authIdMail(mailId:u64)->Result<String>{
let sql = format!("SELECT authIdMail({mailId})");
  Ok(q1!(sql))
}

#[macro_export]
macro_rules! authIdMail {
($mailId:expr) => {
$crate::authIdMail($mailId).await?
};
}

pub async fn authLangId(v:impl AsRef<str>)->Result<u32>{
  Ok(q1!("SELECT authLangId(?)",v.as_ref()))
}

#[macro_export]
macro_rules! authLangId {
($v:expr) => {
$crate::authLangId($v).await?
};
}

pub async fn authMailHostId(v:impl AsRef<str>)->Result<u64>{
  Ok(q1!("SELECT authMailHostId(?)",v.as_ref()))
}

#[macro_export]
macro_rules! authMailHostId {
($v:expr) => {
$crate::authMailHostId($v).await?
};
}

pub async fn authMailId(mail:impl AsRef<str>)->Result<Option<u64>>{
  Ok(q1!("SELECT authMailId(?)",mail.as_ref()))
}

#[macro_export]
macro_rules! authMailId {
($mail:expr) => {
$crate::authMailId($mail).await?
};
}

pub async fn authMailNew(mail:impl AsRef<str>)->Result<u64>{
  Ok(q1!("SELECT authMailNew(?)",mail.as_ref()))
}

#[macro_export]
macro_rules! authMailNew {
($mail:expr) => {
$crate::authMailNew($mail).await?
};
}

pub async fn authMailUid(hostId:u64,mail:impl AsRef<str>)->Result<Option<u64>>{
let sql = format!("SELECT authMailUid({hostId},?)");
  Ok(q1!(sql,mail.as_ref()))
}

#[macro_export]
macro_rules! authMailUid {
($hostId:expr,$mail:expr) => {
$crate::authMailUid($hostId,$mail).await?
};
}

pub async fn authNameId(v:impl AsRef<str>)->Result<u64>{
  Ok(q1!("SELECT authNameId(?)",v.as_ref()))
}

#[macro_export]
macro_rules! authNameId {
($v:expr) => {
$crate::authNameId($v).await?
};
}

pub async fn authNameLog(uid:u64,name:impl AsRef<str>)->Result<()>{
let sql = format!("SELECT authNameLog({uid},?)");
  Ok(e!(sql,name.as_ref()))
}

#[macro_export]
macro_rules! authNameLog {
($uid:expr,$name:expr) => {
$crate::authNameLog($uid,$name).await?
};
}

pub async fn authOsId(v:impl AsRef<str>)->Result<u32>{
  Ok(q1!("SELECT authOsId(?)",v.as_ref()))
}

#[macro_export]
macro_rules! authOsId {
($v:expr) => {
$crate::authOsId($v).await?
};
}

pub async fn authOsVerId(os:impl AsRef<str>,major:u16,minor:u16)->Result<u64>{
let sql = format!("SELECT authOsVerId(?,{major},{minor})");
  Ok(q1!(sql,os.as_ref()))
}

#[macro_export]
macro_rules! authOsVerId {
($os:expr,$major:expr,$minor:expr) => {
$crate::authOsVerId($os,$major,$minor).await?
};
}

pub async fn authPasswdSet(id:u64,hash:[u8;16],ts:u64)->Result<()>{
let sql = format!("SELECT authPasswdSet({id},?,{ts})");
  Ok(e!(sql,hash))
}

#[macro_export]
macro_rules! authPasswdSet {
($id:expr,$hash:expr,$ts:expr) => {
$crate::authPasswdSet($id,$hash,$ts).await?
};
}

pub async fn authUaId(w:u16,h:u16,pixelRatio:u8,zone:i16,cpu:u16,os:impl AsRef<str>,osMajor:u16,osMinor:u16,browser:impl AsRef<str>,browserMajor:u16,browserMinor:u16,gpu:impl AsRef<str>,lang:impl AsRef<str>,arch:impl AsRef<str>)->Result<u64>{
let sql = format!("SELECT authUaId({w},{h},{pixelRatio},{zone},{cpu},?,{osMajor},{osMinor},?,{browserMajor},{browserMinor},?,?,?)");
  Ok(q1!(sql,os.as_ref(),browser.as_ref(),gpu.as_ref(),lang.as_ref(),arch.as_ref()))
}

#[macro_export]
macro_rules! authUaId {
($w:expr,$h:expr,$pixelRatio:expr,$zone:expr,$cpu:expr,$os:expr,$osMajor:expr,$osMinor:expr,$browser:expr,$browserMajor:expr,$browserMinor:expr,$gpu:expr,$lang:expr,$arch:expr) => {
$crate::authUaId($w,$h,$pixelRatio,$zone,$cpu,$os,$osMajor,$osMinor,$browser,$browserMajor,$browserMinor,$gpu,$lang,$arch).await?
};
}

pub async fn authUidMail(uid:u64)->Result<String>{
let sql = format!("SELECT authUidMail({uid})");
  Ok(q1!(sql))
}

#[macro_export]
macro_rules! authUidMail {
($uid:expr) => {
$crate::authUidMail($uid).await?
};
}

pub async fn authUidMailNew(hostId:u64,mail:impl AsRef<str>)->Result<u64>{
let sql = format!("SELECT authUidMailNew({hostId},?)");
  Ok(q1!(sql,mail.as_ref()))
}

#[macro_export]
macro_rules! authUidMailNew {
($hostId:expr,$mail:expr) => {
$crate::authUidMailNew($hostId,$mail).await?
};
}

pub async fn authUidMailUpdate(uid:u64,mail:impl AsRef<str>)->Result<i8>{
let sql = format!("SELECT authUidMailUpdate({uid},?)");
  Ok(q1!(sql,mail.as_ref()))
}

#[macro_export]
macro_rules! authUidMailUpdate {
($uid:expr,$mail:expr) => {
$crate::authUidMailUpdate($uid,$mail).await?
};
}

pub async fn authUidSignIn(uid:u64,clientId:u64,ip:&[u8],authUaId:u64)->Result<()>{
let sql = format!("SELECT authUidSignIn({uid},{clientId},?,{authUaId})");
  Ok(e!(sql,ip))
}

#[macro_export]
macro_rules! authUidSignIn {
($uid:expr,$clientId:expr,$ip:expr,$authUaId:expr) => {
$crate::authUidSignIn($uid,$clientId,$ip,$authUaId).await?
};
}

pub async fn authWidthHeightId(w:u16,h:u16)->Result<u64>{
let sql = format!("SELECT authWidthHeightId({w},{h})");
  Ok(q1!(sql))
}

#[macro_export]
macro_rules! authWidthHeightId {
($w:expr,$h:expr) => {
$crate::authWidthHeightId($w,$h).await?
};
}

pub async fn hostId(host:impl AsRef<str>)->Result<Option<u64>>{
  Ok(q1!("SELECT hostId(?)",host.as_ref()))
}

#[macro_export]
macro_rules! hostId {
($host:expr) => {
$crate::hostId($host).await?
};
}

pub async fn payBillNew(uid:u64,cid:u16,kid:u64,rid:u64,amount:i64,ts:u64)->Result<i64>{
let sql = format!("SELECT payBillNew({uid},{cid},{kid},{rid},{amount},{ts})");
  Ok(q1!(sql))
}

#[macro_export]
macro_rules! payBillNew {
($uid:expr,$cid:expr,$kid:expr,$rid:expr,$amount:expr,$ts:expr) => {
$crate::payBillNew($uid,$cid,$kid,$rid,$amount,$ts).await?
};
}

pub async fn payBrandId(v:&[u8])->Result<u16>{
  Ok(q1!("SELECT payBrandId(?)",v))
}

#[macro_export]
macro_rules! payBrandId {
($v:expr) => {
$crate::payBrandId($v).await?
};
}

pub async fn payIndex(uid:u64,begin:i32,end:i32)->Result<Vec<u8>>{
let sql = format!("SELECT payIndex({uid},{begin},{end})");
  Ok(q1!(sql))
}

#[macro_export]
macro_rules! payIndex {
($uid:expr,$begin:expr,$end:expr) => {
$crate::payIndex($uid,$begin,$end).await?
};
}

pub async fn payStripeRm(uid:u64,id:u64)->Result<u8>{
let sql = format!("SELECT payStripeRm({uid},{id})");
  Ok(q1!(sql))
}

#[macro_export]
macro_rules! payStripeRm {
($uid:expr,$id:expr) => {
$crate::payStripeRm($uid,$id).await?
};
}

pub async fn tokenRefresh(id:u64,uid:u64,sk:u64,day:u64)->Result<i8>{
let sql = format!("SELECT tokenRefresh({id},{uid},{sk},{day})");
  Ok(q1!(sql))
}

#[macro_export]
macro_rules! tokenRefresh {
($id:expr,$uid:expr,$sk:expr,$day:expr) => {
$crate::tokenRefresh($id,$uid,$sk,$day).await?
};
}

pub async fn tokenRm(uid:u64,id:u64)->Result<i8>{
let sql = format!("SELECT tokenRm({uid},{id})");
  Ok(q1!(sql))
}

#[macro_export]
macro_rules! tokenRm {
($uid:expr,$id:expr) => {
$crate::tokenRm($uid,$id).await?
};
}

}

pub use r#fn::*;