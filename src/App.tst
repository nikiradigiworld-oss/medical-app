import { useState, useEffect, useCallback } from "react";

/* ─── data ─────────────────────────────────────────────────── */
const PALETTE = ["#0ea5e9","#8b5cf6","#10b981","#f59e0b","#ec4899","#06b6d4","#ef4444","#14b8a6"];

const INIT_DOCTORS = [
  { id:1, name:"Dr. Sophia Reynolds", specialty:"Cardiologist",       experience:"15 yrs", rating:4.9, avatar:"SR", color:"#0ea5e9", available:true,  slots:["09:00 AM","10:30 AM","02:00 PM","04:00 PM"], bio:"Board-certified cardiologist specialising in heart disease prevention, interventional procedures and cardiac rehab.", patients:2400, education:"Harvard Medical School",         phone:"555-1001", email:"sophia@medicare.com",  languages:"English, Spanish",    awards:"Best Cardiologist 2023",      consultFee:"$150" },
  { id:2, name:"Dr. Marcus Chen",     specialty:"Neurologist",        experience:"12 yrs", rating:4.8, avatar:"MC", color:"#8b5cf6", available:true,  slots:["08:30 AM","11:00 AM","03:00 PM"],             bio:"Expert in neurological disorders with focus on stroke prevention, epilepsy management and brain health.",       patients:1800, education:"Johns Hopkins University",     phone:"555-1002", email:"marcus@medicare.com",   languages:"English, Mandarin",   awards:"Neurology Excellence 2022",   consultFee:"$140" },
  { id:3, name:"Dr. Amara Osei",      specialty:"Pediatrician",       experience:"10 yrs", rating:4.9, avatar:"AO", color:"#10b981", available:true,  slots:["09:30 AM","01:00 PM","03:30 PM","05:00 PM"], bio:"Dedicated pediatrician providing compassionate care for children from newborns to teens.",                   patients:3200, education:"Stanford Medical School",     phone:"555-1003", email:"amara@medicare.com",    languages:"English, French",     awards:"Pediatric Care Award 2023",   consultFee:"$120" },
  { id:4, name:"Dr. Julian Marte",    specialty:"Orthopedic Surgeon", experience:"18 yrs", rating:4.7, avatar:"JM", color:"#f59e0b", available:false, slots:[],                                             bio:"Renowned orthopedic surgeon specialising in joint replacement, sports injuries and minimally invasive spine.",  patients:2100, education:"Yale School of Medicine",     phone:"555-1004", email:"julian@medicare.com",   languages:"English, Portuguese", awards:"Surgical Innovation 2021",    consultFee:"$180" },
  { id:5, name:"Dr. Priya Sharma",    specialty:"Dermatologist",      experience:"8 yrs",  rating:4.8, avatar:"PS", color:"#ec4899", available:true,  slots:["10:00 AM","12:00 PM","02:30 PM","04:30 PM"], bio:"Skin specialist with expertise in cosmetic and medical dermatology, laser treatments and skin cancer.",       patients:1600, education:"Columbia University",          phone:"555-1005", email:"priya@medicare.com",    languages:"English, Hindi",      awards:"Derm Excellence 2022",        consultFee:"$130" },
  { id:6, name:"Dr. Ethan Brooks",    specialty:"General Physician",  experience:"20 yrs", rating:4.9, avatar:"EB", color:"#06b6d4", available:true,  slots:["08:00 AM","09:00 AM","11:30 AM","01:30 PM","03:00 PM"], bio:"Experienced general physician focused on preventive care, chronic disease management and overall wellness.", patients:5000, education:"Mayo Clinic School of Medicine", phone:"555-1006", email:"ethan@medicare.com", languages:"English",             awards:"GP of the Year 2023",         consultFee:"$100" },
];

const INIT_PATIENTS = [
  { id:1, name:"John Williams", age:45, email:"john@email.com",  phone:"555-0101", password:"pass123", bloodGroup:"A+", address:"123 Oak St, NY",       gender:"Male",   dob:"1979-03-15", allergies:"Penicillin", history:["Hypertension","Diabetes"] },
  { id:2, name:"Emily Davis",   age:32, email:"emily@email.com", phone:"555-0102", password:"pass123", bloodGroup:"O-", address:"456 Maple Ave, CA",     gender:"Female", dob:"1992-07-22", allergies:"None",       history:["Asthma"]                  },
];

/* ─── responsive hook ───────────────────────────────────────── */
function useBreakpoint() {
  const [w, setW] = useState(typeof window !== "undefined" ? window.innerWidth : 1200);
  useEffect(() => {
    const fn = () => setW(window.innerWidth);
    window.addEventListener("resize", fn);
    return () => window.removeEventListener("resize", fn);
  }, []);
  return { isMobile: w < 640, isTablet: w < 1024, w };
}

/* ═══════════════════════════════════════════════════════════════
   MAIN APP
═══════════════════════════════════════════════════════════════ */
export default function App() {
  const bp = useBreakpoint();
  const mob = bp.isMobile;
  const tab = bp.isTablet;

  const [page,           setPage]           = useState("home");
  const [menuOpen,       setMenuOpen]       = useState(false);
  const [doctorList,     setDoctorList]     = useState(INIT_DOCTORS);
  const [patientList,    setPatientList]    = useState(INIT_PATIENTS);
  const [appointments,   setAppointments]   = useState([]);
  const [loggedIn,       setLoggedIn]       = useState(false);
  const [currentUser,    setCurrentUser]    = useState(null);

  /* modals */
  const [showAddDoc,     setShowAddDoc]     = useState(false);
  const [showBooking,    setShowBooking]    = useState(false);
  const [bookSuccess,    setBookSuccess]    = useState(false);
  const [docProfile,     setDocProfile]     = useState(null);
  const [patProfile,     setPatProfile]     = useState(null);
  const [editDocModal,   setEditDocModal]   = useState(false);
  const [editDoc,        setEditDoc]        = useState(null);

  /* forms */
  const [loginTab,  setLoginTab]  = useState("patient");
  const [lf,        setLf]        = useState({ email:"", password:"" });
  const [loginErr,  setLoginErr]  = useState("");
  const [isReg,     setIsReg]     = useState(false);
  const [rf,        setRf]        = useState({ name:"", age:"", email:"", phone:"", password:"", bloodGroup:"", address:"", gender:"Male", dob:"", allergies:"", history:"" });
  const [regErr,    setRegErr]    = useState("");
  const [nd,        setNd]        = useState({ name:"", specialty:"", experience:"", bio:"", education:"", slots:"", phone:"", email:"", languages:"", awards:"", consultFee:"" });
  const [selDoc,    setSelDoc]    = useState(null);
  const [selSlot,   setSelSlot]   = useState("");
  const [bookNote,  setBookNote]  = useState("");
  const [fSpec,     setFSpec]     = useState("All");
  const [fAvail,    setFAvail]    = useState(false);
  const [search,    setSearch]    = useState("");

  const specs = ["All", ...new Set(doctorList.map(d=>d.specialty))];
  const fDocs = doctorList.filter(d=>{
    if(fSpec!=="All" && d.specialty!==fSpec) return false;
    if(fAvail && !d.available) return false;
    if(search && !d.name.toLowerCase().includes(search.toLowerCase()) && !d.specialty.toLowerCase().includes(search.toLowerCase())) return false;
    return true;
  });
  const myAppts = appointments.filter(a=>currentUser && a.patientEmail===currentUser.email);

  /* nav helper */
  const go = useCallback((p)=>{ setPage(p); setMenuOpen(false); }, []);

  /* ── auth ── */
  function doLogin(){
    setLoginErr("");
    if(!lf.email||!lf.password){setLoginErr("Fill all fields.");return;}
    if(loginTab==="admin"){
      if(lf.email==="admin@hospital.com"&&lf.password==="admin123"){ setLoggedIn(true);setCurrentUser({name:"Administrator",type:"admin",email:"admin@hospital.com"});go("adminDash"); }
      else setLoginErr("Use admin@hospital.com / admin123");
      return;
    }
    const p=patientList.find(p=>p.email===lf.email&&p.password===lf.password);
    if(p){setLoggedIn(true);setCurrentUser({...p,type:"patient"});go("patientDash");}
    else setLoginErr("Invalid email or password.");
  }
  function doRegister(){
    setRegErr("");
    if(!rf.name||!rf.email||!rf.password){setRegErr("Name, email & password required.");return;}
    if(patientList.find(p=>p.email===rf.email)){setRegErr("Email already registered.");return;}
    const np={id:patientList.length+1,...rf,age:parseInt(rf.age)||0,history:rf.history?rf.history.split(",").map(s=>s.trim()):[]};
    setPatientList([...patientList,np]);
    setLoggedIn(true);setCurrentUser({...np,type:"patient"});go("patientDash");
  }
  function doLogout(){ setLoggedIn(false);setCurrentUser(null);go("home");setLf({email:"",password:""}); }

  function doBook(){
    if(!selDoc||!selSlot) return;
    const a={id:appointments.length+1,doctor:selDoc.name,specialty:selDoc.specialty,doctorColor:selDoc.color,slot:selSlot,patientEmail:currentUser?.email||"guest",patientName:currentUser?.name||"Guest",reason:bookNote,date:new Date().toLocaleDateString(),status:"Confirmed",doctorId:selDoc.id};
    setAppointments([...appointments,a]);
    setBookSuccess(true);
    setTimeout(()=>{setBookSuccess(false);setShowBooking(false);setSelSlot("");setBookNote("");},2800);
  }
  function doAddDoc(){
    if(!nd.name||!nd.specialty) return;
    const doc={id:doctorList.length+1,name:nd.name,specialty:nd.specialty,experience:nd.experience||"N/A",rating:4.5,avatar:nd.name.split(" ").map(n=>n[0]).join("").slice(0,2).toUpperCase(),color:PALETTE[doctorList.length%PALETTE.length],available:true,slots:nd.slots?nd.slots.split(",").map(s=>s.trim()):["10:00 AM","02:00 PM"],bio:nd.bio||"Dedicated healthcare professional.",patients:0,education:nd.education||"Medical School",phone:nd.phone||"",email:nd.email||"",languages:nd.languages||"English",awards:nd.awards||"",consultFee:nd.consultFee||"$100"};
    setDoctorList([...doctorList,doc]);
    setNd({name:"",specialty:"",experience:"",bio:"",education:"",slots:"",phone:"",email:"",languages:"",awards:"",consultFee:""});
    setShowAddDoc(false);
  }
  function doEditDoc(){
    if(!editDoc) return;
    setDoctorList(doctorList.map(d=>d.id===editDoc.id?{...editDoc,slots:typeof editDoc.slots==="string"?editDoc.slots.split(",").map(s=>s.trim()):editDoc.slots}:d));
    setEditDocModal(false);setEditDoc(null);
  }
  function toggleAvail(id){ setDoctorList(doctorList.map(d=>d.id===id?{...d,available:!d.available}:d)); }

  /* ── design tokens ── */
  const R="#e94560", NV="#0f3460", DK="#16213e", DP="#1a1a2e", SL="#64748b", BR="#e2e8f0";

  /* ── shared style helpers ── */
  const card  = { background:"#fff", borderRadius:16, boxShadow:"0 4px 20px rgba(0,0,0,0.07)", border:`1px solid ${BR}` };
  const inp   = { width:"100%", padding:"11px 14px", borderRadius:10, border:`1.5px solid ${BR}`, fontSize:14, fontFamily:"inherit", background:"#f8fafc", outline:"none", boxSizing:"border-box", color:DP };
  const lbl   = { display:"block", fontSize:11, fontWeight:700, color:SL, marginBottom:5, letterSpacing:0.5, textTransform:"uppercase" };
  const btnP  = { background:`linear-gradient(135deg,${R},#c0392b)`, color:"#fff", border:"none", padding:"12px 26px", borderRadius:10, cursor:"pointer", fontSize:14, fontWeight:700, fontFamily:"inherit", boxShadow:"0 6px 18px rgba(233,69,96,0.35)" };
  const btnO  = { background:"transparent", color:NV, border:`2px solid ${NV}`, padding:"11px 22px", borderRadius:10, cursor:"pointer", fontSize:14, fontWeight:600, fontFamily:"inherit" };
  const modal = { position:"fixed", inset:0, background:"rgba(0,0,0,0.65)", display:"flex", alignItems:"center", justifyContent:"center", zIndex:1000, padding:16, backdropFilter:"blur(6px)" };
  const mbox  = { background:"#fff", borderRadius:20, padding: mob?20:32, width:"100%", maxWidth:540, maxHeight:"90vh", overflowY:"auto", boxShadow:"0 25px 60px rgba(0,0,0,0.3)" };
  const badge = (ok) => ({ display:"inline-flex", alignItems:"center", gap:4, background:ok?"#dcfce7":"#fee2e2", color:ok?"#16a34a":"#dc2626", padding:"3px 10px", borderRadius:20, fontSize:11, fontWeight:700 });
  const tag   = (c)  => ({ display:"inline-block", background:`${c}1a`, color:c, padding:"3px 9px", borderRadius:6, fontSize:11, fontWeight:700 });
  const slot  = { display:"inline-block", background:"#f1f5f9", border:`1px solid ${BR}`, color:"#475569", padding:"5px 12px", borderRadius:8, fontSize:12, fontWeight:600, cursor:"pointer" };
  const slotA = { background:NV, color:"#fff", border:`1px solid ${NV}` };
  const ava   = (c,sz=52) => ({ width:sz, height:sz, borderRadius:Math.round(sz*0.26), background:`linear-gradient(135deg,${c},${c}99)`, display:"flex", alignItems:"center", justifyContent:"center", color:"#fff", fontSize:sz*0.33, fontWeight:800, boxShadow:`0 6px 16px ${c}44`, flexShrink:0 });
  const sec   = { padding: mob?"32px 16px":"50px 32px", maxWidth:1200, margin:"0 auto" };
  const g2    = { display:"grid", gridTemplateColumns: tab?"1fr":"1fr 1fr", gap:20 };
  const g3    = { display:"grid", gridTemplateColumns: mob?"1fr":tab?"1fr 1fr":"repeat(3,1fr)", gap:20 };

  /* ════════════════════════════════════
     NAV
  ════════════════════════════════════ */
  function Nav(){
    const navLinks=[
      {p:"home",l:"Home"},{p:"doctors",l:"Doctors"},{p:"appointments",l:"Appointments"},
      ...(loggedIn&&currentUser?.type==="admin"?[{p:"adminDash",l:"Admin"}]:[]),
      ...(loggedIn&&currentUser?.type==="patient"?[{p:"patientDash",l:"My Portal"}]:[]),
    ];
    return(
      <nav style={{ background:`linear-gradient(135deg,${NV},${DK})`, position:"sticky", top:0, zIndex:200, boxShadow:"0 4px 20px rgba(0,0,0,0.3)" }}>
        <div style={{ padding: mob?"0 16px":"0 28px", height:62, display:"flex", alignItems:"center", justifyContent:"space-between" }}>
          {/* logo */}
          <div style={{ display:"flex", alignItems:"center", gap:10, cursor:"pointer" }} onClick={()=>go("home")}>
            <div style={{ width:38, height:38, background:`linear-gradient(135deg,${R},#c0392b)`, borderRadius:9, display:"flex", alignItems:"center", justifyContent:"center", fontSize:18, fontWeight:900, color:"#fff" }}>✚</div>
            <div>
              <div style={{ color:"#fff", fontSize: mob?16:18, fontWeight:700, letterSpacing:"-0.5px", lineHeight:1 }}>MediCare<span style={{color:R}}>+</span></div>
              {!mob&&<div style={{ color:"#94a3b8", fontSize:9, letterSpacing:2, textTransform:"uppercase" }}>Advanced Healthcare</div>}
            </div>
          </div>

          {/* desktop links */}
          {!mob&&(
            <div style={{ display:"flex", gap:4, alignItems:"center" }}>
              {navLinks.map(({p,l})=>(
                <button key={p} onClick={()=>go(p)} style={{ background:page===p?"rgba(233,69,96,0.18)":"transparent", border:page===p?"1px solid rgba(233,69,96,0.4)":"1px solid transparent", color:page===p?R:"#94a3b8", padding:"7px 14px", borderRadius:8, cursor:"pointer", fontSize:13, fontWeight:600, fontFamily:"inherit" }}>{l}</button>
              ))}
              {loggedIn?(
                <div style={{ display:"flex", alignItems:"center", gap:8, marginLeft:8 }}>
                  <div style={{ width:30, height:30, borderRadius:"50%", background:`linear-gradient(135deg,${R},#c0392b)`, display:"flex", alignItems:"center", justifyContent:"center", color:"#fff", fontSize:13, fontWeight:800 }}>{currentUser?.name?.[0]}</div>
                  <span style={{ color:"#e2e8f0", fontSize:13 }}>{currentUser?.name?.split(" ")[0]}</span>
                  <button onClick={doLogout} style={{ background:"transparent", border:"1px solid transparent", color:"#f87171", padding:"7px 12px", borderRadius:8, cursor:"pointer", fontSize:13, fontWeight:600, fontFamily:"inherit" }}>Logout</button>
                </div>
              ):(
                <button onClick={()=>go("login")} style={{ ...btnP, padding:"8px 18px", fontSize:13, marginLeft:8 }}>Login / Register</button>
              )}
            </div>
          )}

          {/* mobile hamburger */}
          {mob&&(
            <button onClick={()=>setMenuOpen(o=>!o)} style={{ background:"transparent", border:"none", color:"#fff", fontSize:24, cursor:"pointer", padding:4 }}>
              {menuOpen?"✕":"☰"}
            </button>
          )}
        </div>

        {/* mobile drawer */}
        {mob&&menuOpen&&(
          <div style={{ background:DK, borderTop:"1px solid rgba(255,255,255,0.1)", padding:"12px 0 16px" }}>
            {navLinks.map(({p,l})=>(
              <button key={p} onClick={()=>go(p)} style={{ display:"block", width:"100%", textAlign:"left", background:page===p?"rgba(233,69,96,0.15)":"transparent", border:"none", color:page===p?R:"#94a3b8", padding:"12px 20px", fontSize:15, fontWeight:600, cursor:"pointer", fontFamily:"inherit" }}>{l}</button>
            ))}
            <div style={{ height:1, background:"rgba(255,255,255,0.1)", margin:"10px 0" }}/>
            {loggedIn?(
              <button onClick={doLogout} style={{ display:"block", width:"100%", textAlign:"left", background:"transparent", border:"none", color:"#f87171", padding:"12px 20px", fontSize:15, fontWeight:600, cursor:"pointer", fontFamily:"inherit" }}>Logout ({currentUser?.name?.split(" ")[0]})</button>
            ):(
              <button onClick={()=>go("login")} style={{ ...btnP, margin:"8px 16px 0", display:"block", textAlign:"center" }}>Login / Register</button>
            )}
          </div>
        )}
      </nav>
    );
  }

  /* ════════════════════════════════════
     HOME
  ════════════════════════════════════ */
  function HomePage(){
    return(
      <div>
        {/* hero */}
        <div style={{ background:`linear-gradient(135deg,${NV} 0%,${DK} 60%,${DP} 100%)`, padding: mob?"52px 20px 44px":tab?"64px 36px":"80px 48px", textAlign:"center", position:"relative", overflow:"hidden" }}>
          <div style={{ position:"absolute", inset:0, backgroundImage:"radial-gradient(circle at 20% 50%,rgba(233,69,96,0.09) 0%,transparent 60%),radial-gradient(circle at 80% 20%,rgba(14,165,233,0.07) 0%,transparent 50%)" }}/>
          <div style={{ position:"relative", zIndex:1 }}>
            <div style={{ display:"inline-block", background:"rgba(233,69,96,0.13)", border:"1px solid rgba(233,69,96,0.3)", color:R, padding:"5px 16px", borderRadius:30, fontSize:11, fontWeight:700, letterSpacing:2, textTransform:"uppercase", marginBottom:18 }}>🏥 Trusted Healthcare Since 1995</div>
            <h1 style={{ color:"#fff", fontSize: mob?30:tab?40:52, fontWeight:800, lineHeight:1.15, marginBottom:16, letterSpacing:"-1px" }}>
              Your Health, Our<br/><span style={{color:R}}>Priority & Promise</span>
            </h1>
            <p style={{ color:"#94a3b8", fontSize: mob?14:17, maxWidth:520, margin:"0 auto 30px", lineHeight:1.75 }}>
              World-class medical care with compassion. Book appointments with top specialists and get the care you deserve.
            </p>
            <div style={{ display:"flex", gap:12, justifyContent:"center", flexWrap:"wrap" }}>
              <button style={{ ...btnP, padding: mob?"11px 20px":"13px 28px", fontSize: mob?13:15 }} onClick={()=>go("appointments")}>📅 Book Appointment</button>
              <button style={{ ...btnO, color:"#e2e8f0", borderColor:"rgba(255,255,255,0.3)", padding: mob?"11px 18px":"13px 24px", fontSize: mob?13:15 }} onClick={()=>go("doctors")}>👨‍⚕️ Our Doctors</button>
              <button style={{ ...btnO, color:"#94a3b8", borderColor:"rgba(255,255,255,0.2)", padding: mob?"11px 16px":"13px 22px", fontSize: mob?13:14 }} onClick={()=>{ setIsReg(true);go("login"); }}>👤 Register</button>
            </div>
            {/* stats */}
            <div style={{ display:"flex", justifyContent:"center", gap: mob?12:28, marginTop: mob?36:52, flexWrap:"wrap" }}>
              {[["50+","Doctors"],["25K+","Patients"],["98%","Satisfaction"],["24/7","Emergency"]].map(([n,l])=>(
                <div key={l} style={{ background:"rgba(255,255,255,0.07)", backdropFilter:"blur(10px)", border:"1px solid rgba(255,255,255,0.1)", padding: mob?"14px 18px":"18px 28px", borderRadius:14, textAlign:"center", minWidth: mob?68:90 }}>
                  <div style={{ color:R, fontSize: mob?22:28, fontWeight:900, letterSpacing:"-0.5px" }}>{n}</div>
                  <div style={{ color:"#94a3b8", fontSize: mob?10:11, fontWeight:600, letterSpacing:1, textTransform:"uppercase", marginTop:3 }}>{l}</div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* services */}
        <div style={sec}>
          <div style={{ textAlign:"center", marginBottom:32 }}>
            <h2 style={{ fontSize: mob?22:28, fontWeight:800, marginBottom:6 }}>Our Medical Services</h2>
            <p style={{ color:SL }}>Comprehensive care across all specialties</p>
          </div>
          <div style={{ display:"grid", gridTemplateColumns: mob?"1fr 1fr":tab?"repeat(3,1fr)":"repeat(6,1fr)", gap:14 }}>
            {[["❤️","Cardiology","#e94560"],["🧠","Neurology","#8b5cf6"],["👶","Pediatrics","#10b981"],["🦴","Orthopedics","#f59e0b"],["🔬","Dermatology","#ec4899"],["💊","General","#06b6d4"]].map(([icon,name,color])=>(
              <div key={name} style={{ ...card, padding: mob?"18px 12px":22, textAlign:"center" }}>
                <div style={{ fontSize: mob?28:32, marginBottom:8 }}>{icon}</div>
                <div style={{ fontWeight:800, color:DP, fontSize: mob?12:14, marginBottom:6 }}>{name}</div>
                <span style={tag(color)}>Available</span>
              </div>
            ))}
          </div>
        </div>

        {/* featured doctors */}
        <div style={{ background:"#f1f5f9", padding: mob?"32px 16px":"50px 32px" }}>
          <div style={{ maxWidth:1200, margin:"0 auto" }}>
            <h2 style={{ fontSize: mob?22:28, fontWeight:800, marginBottom:4 }}>Featured Doctors</h2>
            <p style={{ color:SL, marginBottom:24 }}>Meet our top-rated specialists</p>
            <div style={g3}>
              {doctorList.filter(d=>d.available).slice(0,mob?2:3).map(d=><DoctorCard key={d.id} doc={d}/>)}
            </div>
            <div style={{ textAlign:"center", marginTop:28 }}>
              <button style={btnP} onClick={()=>go("doctors")}>View All Doctors →</button>
            </div>
          </div>
        </div>

        {/* CTA */}
        <div style={{ background:`linear-gradient(135deg,${NV},${DK})`, padding: mob?"40px 20px":"56px 48px", textAlign:"center" }}>
          <h2 style={{ color:"#fff", fontSize: mob?22:30, fontWeight:800, marginBottom:12 }}>New Patient? Create Your Account</h2>
          <p style={{ color:"#94a3b8", marginBottom:26, fontSize: mob?14:16 }}>Register to book appointments, track your health history, and manage your care.</p>
          <div style={{ display:"flex", gap:12, justifyContent:"center", flexWrap:"wrap" }}>
            <button style={btnP} onClick={()=>{ setIsReg(true);go("login"); }}>Create Patient Account</button>
            <button style={{ ...btnO, color:"#e2e8f0", borderColor:"rgba(255,255,255,0.3)" }} onClick={()=>{ setIsReg(false);go("login"); }}>Patient Login</button>
          </div>
        </div>
      </div>
    );
  }

  /* ════════════════════════════════════
     DOCTOR CARD
  ════════════════════════════════════ */
  function DoctorCard({doc}){
    return(
      <div style={{ ...card, overflow:"hidden", opacity:doc.available?1:0.8 }}>
        <div style={{ background:`linear-gradient(135deg,${doc.color}18,${doc.color}08)`, borderBottom:`3px solid ${doc.color}`, padding:"20px 20px 14px", display:"flex", gap:14, alignItems:"flex-start" }}>
          <div style={ava(doc.color,52)}>{doc.avatar}</div>
          <div style={{ flex:1, minWidth:0 }}>
            <div style={{ fontWeight:800, fontSize: mob?13:15, color:DP, marginBottom:4, lineHeight:1.3 }}>{doc.name}</div>
            <span style={{ ...tag(doc.color), display:"inline-block", marginBottom:7 }}>{doc.specialty}</span><br/>
            <span style={badge(doc.available)}><span style={{ width:6,height:6,borderRadius:"50%",background:doc.available?"#16a34a":"#dc2626" }}/>{doc.available?"Available":"Off"}</span>
          </div>
          <div style={{ textAlign:"right", fontSize:12, color:SL, flexShrink:0 }}>
            <div style={{ fontWeight:800, color:DP, fontSize:15 }}>⭐ {doc.rating}</div>
            <div>{doc.experience}</div>
            <div style={{ fontWeight:700, color:R, marginTop:4 }}>{doc.consultFee}</div>
          </div>
        </div>
        <div style={{ padding:"16px 20px" }}>
          <p style={{ fontSize:13, color:SL, lineHeight:1.6, marginBottom:12, display:"-webkit-box", WebkitLineClamp:2, WebkitBoxOrient:"vertical", overflow:"hidden" }}>{doc.bio}</p>
          {doc.available&&doc.slots.length>0&&(
            <div style={{ marginBottom:12 }}>
              <div style={{ fontSize:10, fontWeight:700, color:"#94a3b8", marginBottom:6, textTransform:"uppercase", letterSpacing:1 }}>Slots</div>
              <div style={{ display:"flex", flexWrap:"wrap", gap:5 }}>
                {doc.slots.slice(0,mob?2:4).map(s=><span key={s} style={slot}>{s}</span>)}
                {doc.slots.length>(mob?2:4)&&<span style={{ ...slot, background:"#f1f5f9" }}>+{doc.slots.length-(mob?2:4)}</span>}
              </div>
            </div>
          )}
          <div style={{ display:"flex", gap:8 }}>
            <button style={{ ...btnP, padding:"9px 12px", fontSize:13, flex:2 }} onClick={()=>{ setSelDoc(doc);setShowBooking(true); }} disabled={!doc.available}>{doc.available?"📅 Book":"Unavailable"}</button>
            <button style={{ ...btnO, padding:"9px 12px", fontSize:13, flex:1 }} onClick={()=>setDocProfile(doc)}>Profile</button>
            {loggedIn&&currentUser?.type==="admin"&&(
              <button style={{ background:"#f1f5f9", border:`1px solid ${BR}`, borderRadius:10, padding:"9px 10px", cursor:"pointer", fontSize:13 }} onClick={()=>{ setEditDoc({...doc,slots:doc.slots.join(", ")});setEditDocModal(true); }}>✏️</button>
            )}
          </div>
        </div>
      </div>
    );
  }

  /* ════════════════════════════════════
     DOCTORS PAGE
  ════════════════════════════════════ */
  function DoctorsPage(){
    return(
      <div style={sec}>
        <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-start", flexWrap:"wrap", gap:12, marginBottom:24 }}>
          <div>
            <h2 style={{ fontSize: mob?22:28, fontWeight:800, marginBottom:4 }}>Our Medical Team</h2>
            <p style={{ color:SL }}>{fDocs.length} doctor{fDocs.length!==1?"s":""} found</p>
          </div>
          {loggedIn&&currentUser?.type==="admin"&&(
            <button style={{ ...btnP, padding:"10px 18px", fontSize:13 }} onClick={()=>setShowAddDoc(true)}>+ Add Doctor</button>
          )}
        </div>

        {/* search + filters */}
        <div style={{ display:"flex", flexDirection: mob?"column":"row", gap:10, marginBottom:20, flexWrap:"wrap" }}>
          <input style={{ ...inp, width: mob?"100%":220 }} placeholder="🔍 Search name or specialty…" value={search} onChange={e=>setSearch(e.target.value)}/>
          <div style={{ display:"flex", gap:6, flexWrap:"wrap" }}>
            {specs.map(s=>(
              <button key={s} style={{ ...slot, ...(fSpec===s?slotA:{}), fontFamily:"inherit" }} onClick={()=>setFSpec(s)}>{s}</button>
            ))}
          </div>
          <label style={{ display:"flex", alignItems:"center", gap:7, fontSize:13, fontWeight:600, color:SL, cursor:"pointer" }}>
            <input type="checkbox" checked={fAvail} onChange={e=>setFAvail(e.target.checked)}/> Available Only
          </label>
        </div>

        <div style={g3}>
          {fDocs.map(d=><DoctorCard key={d.id} doc={d}/>)}
        </div>
        {fDocs.length===0&&(
          <div style={{ textAlign:"center", padding:"60px 0", color:SL }}>
            <div style={{ fontSize:44, marginBottom:10 }}>🔍</div>
            <div style={{ fontWeight:700, fontSize:17 }}>No doctors found</div>
            <p>Try adjusting your search or filters</p>
          </div>
        )}
      </div>
    );
  }

  /* ════════════════════════════════════
     APPOINTMENTS PAGE
  ════════════════════════════════════ */
  function AppointmentsPage(){
    return(
      <div style={sec}>
        <h2 style={{ fontSize: mob?22:28, fontWeight:800, marginBottom:4 }}>Book an Appointment</h2>
        <p style={{ color:SL, marginBottom:24 }}>Choose a specialist and pick a time that suits you</p>

        {!loggedIn&&(
          <div style={{ ...card, background:"#fffbeb", border:"1px solid #fbbf24", marginBottom:22, padding:18, display:"flex", gap:14, alignItems:"center", flexWrap:"wrap" }}>
            <span style={{ fontSize:26 }}>⚠️</span>
            <div>
              <div style={{ fontWeight:700, color:"#92400e", marginBottom:8 }}>Please log in to book appointments</div>
              <button style={{ ...btnP, padding:"8px 16px", fontSize:13 }} onClick={()=>go("login")}>Login / Register</button>
            </div>
          </div>
        )}

        {myAppts.length>0&&(
          <div style={{ marginBottom:32 }}>
            <h3 style={{ fontWeight:800, marginBottom:14 }}>Your Upcoming Appointments</h3>
            <div style={{ display:"grid", gridTemplateColumns: mob?"1fr":tab?"1fr 1fr":"repeat(3,1fr)", gap:14 }}>
              {myAppts.map(a=>(
                <div key={a.id} style={{ ...card, padding:18, borderLeft:`4px solid ${a.doctorColor||R}` }}>
                  <div style={{ display:"flex", justifyContent:"space-between", marginBottom:8 }}>
                    <div style={{ fontWeight:800, fontSize:14 }}>{a.doctor}</div>
                    <span style={badge(true)}>{a.status}</span>
                  </div>
                  <div style={{ fontSize:13, color:SL, lineHeight:1.9 }}>
                    <div>🩺 {a.specialty}</div><div>🕐 {a.slot} · {a.date}</div>
                    {a.reason&&<div>📝 {a.reason}</div>}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        <h3 style={{ fontWeight:800, marginBottom:18 }}>Available Doctors</h3>
        <div style={g3}>{doctorList.filter(d=>d.available).map(d=><DoctorCard key={d.id} doc={d}/>)}</div>
      </div>
    );
  }

  /* ════════════════════════════════════
     LOGIN / REGISTER PAGE
  ════════════════════════════════════ */
  function LoginPage(){
    return(
      <div style={{ ...sec, paddingTop:40, paddingBottom:56 }}>
        <div style={{ display:"grid", gridTemplateColumns: tab?"1fr":"1fr 1fr", gap:22, maxWidth:860, margin:"0 auto" }}>

          {/* form card */}
          <div style={{ ...card, padding: mob?20:32 }}>
            <div style={{ textAlign:"center", marginBottom:24 }}>
              <div style={{ width:46,height:46,background:`linear-gradient(135deg,${R},#c0392b)`,borderRadius:11,display:"flex",alignItems:"center",justifyContent:"center",fontSize:20,color:"#fff",margin:"0 auto 12px" }}>✚</div>
              <h2 style={{ fontSize: mob?20:22, fontWeight:800, marginBottom:4 }}>{isReg?"Create Patient Account":"Welcome Back"}</h2>
              <p style={{ color:SL, fontSize:13 }}>{isReg?"Register to access your health portal":"Sign in to your account"}</p>
            </div>

            {!isReg&&(
              <div style={{ display:"flex", gap:6, marginBottom:20, background:"#f1f5f9", borderRadius:10, padding:4 }}>
                {[["patient","👤 Patient"],["admin","🔑 Admin"]].map(([t,l])=>(
                  <button key={t} style={{ flex:1, padding:"9px", border:"none", borderRadius:8, cursor:"pointer", background:loginTab===t?"#fff":"transparent", color:loginTab===t?NV:SL, fontWeight:700, fontSize:13, fontFamily:"inherit", boxShadow:loginTab===t?"0 2px 8px rgba(0,0,0,0.1)":"none" }} onClick={()=>{ setLoginTab(t);setLoginErr(""); }}>{l}</button>
                ))}
              </div>
            )}

            {loginErr&&<div style={{ background:"#fef2f2",border:"1px solid #fecaca",color:"#dc2626",padding:"10px 14px",borderRadius:10,marginBottom:14,fontSize:13 }}>{loginErr}</div>}
            {regErr&&<div style={{ background:"#fef2f2",border:"1px solid #fecaca",color:"#dc2626",padding:"10px 14px",borderRadius:10,marginBottom:14,fontSize:13 }}>{regErr}</div>}

            <div style={{ display:"flex", flexDirection:"column", gap:13 }}>
              {isReg?(
                <>
                  {[["name","Full Name *","Jane Doe"],["age","Age","28"],["phone","Phone","555-0100"],["bloodGroup","Blood Group","A+"],["address","Address","123 Main St"],["allergies","Known Allergies","None"],["history","Medical History (comma-sep)","Diabetes, Asthma"]].map(([k,l,ph])=>(
                    <div key={k}><label style={lbl}>{l}</label><input style={inp} placeholder={ph} value={rf[k]} onChange={e=>setRf({...rf,[k]:e.target.value})}/></div>
                  ))}
                  <div><label style={lbl}>Date of Birth</label><input style={inp} type="date" value={rf.dob} onChange={e=>setRf({...rf,dob:e.target.value})}/></div>
                  <div><label style={lbl}>Gender</label><select style={inp} value={rf.gender} onChange={e=>setRf({...rf,gender:e.target.value})}><option>Male</option><option>Female</option><option>Other</option></select></div>
                  <div><label style={lbl}>Email *</label><input style={inp} type="email" placeholder="you@email.com" value={rf.email} onChange={e=>setRf({...rf,email:e.target.value})}/></div>
                  <div><label style={lbl}>Password *</label><input style={inp} type="password" placeholder="••••••••" value={rf.password} onChange={e=>setRf({...rf,password:e.target.value})}/></div>
                  <button style={{ ...btnP, marginTop:6 }} onClick={doRegister}>Create Account</button>
                </>
              ):(
                <>
                  <div><label style={lbl}>Email</label><input style={inp} type="email" placeholder={loginTab==="admin"?"admin@hospital.com":"john@email.com"} value={lf.email} onChange={e=>setLf({...lf,email:e.target.value})}/></div>
                  <div><label style={lbl}>Password</label><input style={inp} type="password" placeholder="••••••••" value={lf.password} onChange={e=>setLf({...lf,password:e.target.value})}/></div>
                  <div style={{ background:"#f8fafc",border:`1px solid ${BR}`,borderRadius:10,padding:"10px 14px",fontSize:12,color:"#94a3b8" }}>
                    {loginTab==="admin"?"Demo admin: admin@hospital.com / admin123":"Demo patient: john@email.com / pass123"}
                  </div>
                  <button style={{ ...btnP, marginTop:4 }} onClick={doLogin}>Sign In</button>
                </>
              )}
            </div>

            <div style={{ textAlign:"center", marginTop:16, fontSize:13, color:SL }}>
              {isReg?"Already registered? ":"New patient? "}
              <span style={{ color:R, fontWeight:700, cursor:"pointer" }} onClick={()=>{ setIsReg(!isReg);setLoginErr("");setRegErr(""); }}>{isReg?"Sign In":"Create Account"}</span>
            </div>
          </div>

          {/* info panel – hide on mobile to reduce scroll */}
          {!mob&&(
            <div style={{ display:"flex", flexDirection:"column", gap:16 }}>
              <div style={{ ...card, background:`linear-gradient(135deg,${NV},${DK})`, color:"#fff", padding:28 }}>
                <h3 style={{ fontWeight:800, fontSize:17, marginBottom:14, color:"#fff" }}>Patient Portal Benefits</h3>
                {["📅 Easy online appointment booking","📋 View your medical history","💊 Track prescriptions & reports","👨‍⚕️ Direct doctor profiles","🔔 Appointment confirmations","🏥 Emergency contact management"].map(b=>(
                  <div key={b} style={{ fontSize:13, color:"#94a3b8", padding:"7px 0", borderBottom:"1px solid rgba(255,255,255,0.07)" }}>{b}</div>
                ))}
              </div>
              <div style={{ ...card, padding:24 }}>
                <h3 style={{ fontWeight:800, fontSize:15, marginBottom:12 }}>Emergency Contact</h3>
                <div style={{ fontSize:13, color:SL, lineHeight:2 }}>
                  <div>🚨 Emergency: <b style={{color:R}}>911</b></div>
                  <div>📞 Helpline: <b>1-800-MEDICARE</b></div>
                  <div>🕐 Open 24/7</div>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    );
  }

  /* ════════════════════════════════════
     PATIENT DASHBOARD
  ════════════════════════════════════ */
  function PatientDashboard(){
    const p=currentUser;
    return(
      <div style={sec}>
        {/* header */}
        <div style={{ display:"flex", justifyContent:"space-between", alignItems: mob?"flex-start":"center", flexWrap:"wrap", gap:14, marginBottom:28 }}>
          <div style={{ display:"flex", gap:14, alignItems:"center" }}>
            <div style={{ ...ava(R,mob?52:64), fontSize:mob?20:24 }}>{p?.name?.[0]}</div>
            <div>
              <div style={{ fontSize: mob?18:22, fontWeight:800, marginBottom:2 }}>Welcome, {p?.name?.split(" ")[0]}! 👋</div>
              <div style={{ color:SL, fontSize:13 }}>{p?.email}</div>
              <span style={badge(true)}>Active Patient</span>
            </div>
          </div>
          <button style={{ ...btnP, padding:"10px 18px", fontSize:13 }} onClick={()=>go("appointments")}>📅 Book Now</button>
        </div>

        {/* stats */}
        <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:14, marginBottom:26 }}>
          {[["📅","Appointments",myAppts.length,R],["✅","Confirmed",myAppts.filter(a=>a.status==="Confirmed").length,"#10b981"],["👨‍⚕️","Doctors Visited",new Set(myAppts.map(a=>a.doctor)).size,NV],["💊","Medical Records",(p?.history||[]).length,"#8b5cf6"]].map(([icon,label,val,color])=>(
            <div key={label} style={{ ...card, display:"flex", alignItems:"center", gap:12, padding:mob?14:18 }}>
              <div style={{ width:40,height:40,borderRadius:11,background:`${color}18`,display:"flex",alignItems:"center",justifyContent:"center",fontSize:18,flexShrink:0 }}>{icon}</div>
              <div><div style={{ fontSize:mob?20:24, fontWeight:900, color }}>{val}</div><div style={{ fontSize:11, color:SL, fontWeight:600 }}>{label}</div></div>
            </div>
          ))}
        </div>

        <div style={g2}>
          {/* profile */}
          <div style={{ ...card, padding:mob?18:24 }}>
            <h3 style={{ fontWeight:800, fontSize:16, marginBottom:16 }}>My Profile</h3>
            {[["👤 Name",p?.name],["📧 Email",p?.email],["📞 Phone",p?.phone||"—"],["🩸 Blood",p?.bloodGroup||"—"],["⚧ Gender",p?.gender||"—"],["🎂 DOB",p?.dob||"—"],["💊 Allergies",p?.allergies||"None"],["🏠 Address",p?.address||"—"]].map(([l,v])=>(
              <div key={l} style={{ display:"flex", gap:10, alignItems:"flex-start", padding:"6px 0", borderBottom:`1px solid #f1f5f9` }}>
                <span style={{ fontSize:13, fontWeight:700, color:SL, minWidth:mob?90:110, flexShrink:0 }}>{l}</span>
                <span style={{ fontSize:13, color:DP, fontWeight:600, wordBreak:"break-all" }}>{v}</span>
              </div>
            ))}
            {(p?.history||[]).length>0&&(
              <div style={{ marginTop:14, padding:12, background:"#f8fafc", borderRadius:12 }}>
                <div style={{ fontSize:10, fontWeight:700, color:"#94a3b8", textTransform:"uppercase", letterSpacing:1, marginBottom:8 }}>Medical History</div>
                <div style={{ display:"flex", flexWrap:"wrap", gap:6 }}>{p.history.map(h=><span key={h} style={tag("#8b5cf6")}>{h}</span>)}</div>
              </div>
            )}
          </div>

          {/* appointments */}
          <div>
            <h3 style={{ fontWeight:800, fontSize:16, marginBottom:14 }}>My Appointments</h3>
            {myAppts.length===0?(
              <div style={{ ...card, textAlign:"center", padding:36 }}>
                <div style={{ fontSize:38, marginBottom:10 }}>📅</div>
                <div style={{ fontWeight:700, marginBottom:8 }}>No appointments yet</div>
                <p style={{ color:SL, fontSize:13, marginBottom:16 }}>Book your first appointment today</p>
                <button style={btnP} onClick={()=>go("appointments")}>Book Now</button>
              </div>
            ):(
              <div style={{ display:"flex", flexDirection:"column", gap:12 }}>
                {myAppts.map(a=>(
                  <div key={a.id} style={{ ...card, padding:16, borderLeft:`4px solid ${a.doctorColor||R}` }}>
                    <div style={{ display:"flex", justifyContent:"space-between", marginBottom:8 }}>
                      <div style={{ fontWeight:800, fontSize:14 }}>{a.doctor}</div>
                      <span style={badge(true)}>{a.status}</span>
                    </div>
                    <div style={{ fontSize:13, color:SL, lineHeight:1.9 }}>
                      <div>🩺 {a.specialty} · 🕐 {a.slot}</div>
                      <div>📅 {a.date}{a.reason&&` · 📝 ${a.reason}`}</div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    );
  }

  /* ════════════════════════════════════
     ADMIN DASHBOARD
  ════════════════════════════════════ */
  function AdminDashboard(){
    return(
      <div style={sec}>
        <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", flexWrap:"wrap", gap:14, marginBottom:26 }}>
          <div>
            <h2 style={{ fontSize: mob?22:26, fontWeight:800, marginBottom:4 }}>Admin Dashboard 🔑</h2>
            <p style={{ color:SL }}>Hospital management overview</p>
          </div>
          <button style={{ ...btnP, padding:"10px 18px", fontSize:13 }} onClick={()=>setShowAddDoc(true)}>+ Add Doctor</button>
        </div>

        {/* stats row */}
        <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:14, marginBottom:28 }}>
          {[["👨‍⚕️","Doctors",doctorList.length,NV],["✅","Available",doctorList.filter(d=>d.available).length,"#10b981"],["📅","Appointments",appointments.length,R],["👥","Patients",patientList.length,"#8b5cf6"]].map(([icon,label,val,color])=>(
            <div key={label} style={{ ...card, display:"flex", alignItems:"center", gap:12, padding:mob?14:20 }}>
              <div style={{ width:42,height:42,borderRadius:11,background:`${color}18`,display:"flex",alignItems:"center",justifyContent:"center",fontSize:20,flexShrink:0 }}>{icon}</div>
              <div><div style={{ fontSize:mob?22:26, fontWeight:900, color }}>{val}</div><div style={{ fontSize:11, color:SL, fontWeight:600 }}>{label}</div></div>
            </div>
          ))}
        </div>

        {/* doctor list – scroll table on mobile */}
        <div style={{ marginBottom:32 }}>
          <h3 style={{ fontWeight:800, marginBottom:14 }}>Doctor Management</h3>
          <div style={{ ...card, padding:0, overflowX:"auto" }}>
            <table style={{ width:"100%", borderCollapse:"collapse", fontSize: mob?12:13, minWidth:600 }}>
              <thead><tr style={{ background:"#f8fafc" }}>
                {["Doctor","Specialty","Exp","Rating","Status","Actions"].map(h=>(
                  <th key={h} style={{ padding:"11px 14px", textAlign:"left", fontWeight:700, color:SL, fontSize:10, letterSpacing:0.5, textTransform:"uppercase", whiteSpace:"nowrap" }}>{h}</th>
                ))}
              </tr></thead>
              <tbody>
                {doctorList.map(d=>(
                  <tr key={d.id} style={{ borderTop:"1px solid #f1f5f9" }}>
                    <td style={{ padding:"12px 14px" }}>
                      <div style={{ display:"flex", gap:8, alignItems:"center" }}>
                        <div style={{ ...ava(d.color,32), fontSize:11, borderRadius:8 }}>{d.avatar}</div>
                        <div><div style={{ fontWeight:700, whiteSpace:"nowrap" }}>{d.name}</div><div style={{ fontSize:10, color:SL }}>{d.consultFee}</div></div>
                      </div>
                    </td>
                    <td style={{ padding:"12px 14px" }}><span style={tag(d.color)}>{d.specialty}</span></td>
                    <td style={{ padding:"12px 14px", color:SL, whiteSpace:"nowrap" }}>{d.experience}</td>
                    <td style={{ padding:"12px 14px" }}>⭐ {d.rating}</td>
                    <td style={{ padding:"12px 14px" }}><span style={badge(d.available)}>{d.available?"Active":"Off"}</span></td>
                    <td style={{ padding:"12px 14px" }}>
                      <div style={{ display:"flex", gap:5 }}>
                        <button style={{ background:"#f1f5f9",border:`1px solid ${BR}`,borderRadius:7,padding:"4px 8px",cursor:"pointer",fontSize:11 }} onClick={()=>setDocProfile(d)}>View</button>
                        <button style={{ background:"#f1f5f9",border:`1px solid ${BR}`,borderRadius:7,padding:"4px 8px",cursor:"pointer",fontSize:11 }} onClick={()=>{ setEditDoc({...d,slots:d.slots.join(", ")});setEditDocModal(true); }}>Edit</button>
                        <button style={{ background:d.available?"#fee2e2":"#dcfce7",border:"none",borderRadius:7,padding:"4px 8px",cursor:"pointer",fontSize:11,color:d.available?"#dc2626":"#16a34a",fontWeight:700 }} onClick={()=>toggleAvail(d.id)}>{d.available?"Disable":"Enable"}</button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* patient list */}
        <div style={{ marginBottom:32 }}>
          <h3 style={{ fontWeight:800, marginBottom:14 }}>Patient List</h3>
          <div style={{ ...card, padding:0, overflowX:"auto" }}>
            <table style={{ width:"100%", borderCollapse:"collapse", fontSize: mob?12:13, minWidth:500 }}>
              <thead><tr style={{ background:"#f8fafc" }}>
                {["#","Patient","Contact","Blood","History",""].map(h=>(
                  <th key={h} style={{ padding:"11px 14px", textAlign:"left", fontWeight:700, color:SL, fontSize:10, letterSpacing:0.5, textTransform:"uppercase" }}>{h}</th>
                ))}
              </tr></thead>
              <tbody>
                {patientList.map((p,i)=>(
                  <tr key={p.id} style={{ borderTop:"1px solid #f1f5f9" }}>
                    <td style={{ padding:"12px 14px", color:"#94a3b8" }}>{i+1}</td>
                    <td style={{ padding:"12px 14px" }}><div style={{ fontWeight:700 }}>{p.name}</div><div style={{ fontSize:11, color:SL }}>Age {p.age}</div></td>
                    <td style={{ padding:"12px 14px", color:SL }}><div style={{ whiteSpace:"nowrap" }}>{p.email}</div><div>{p.phone}</div></td>
                    <td style={{ padding:"12px 14px" }}><span style={tag(R)}>{p.bloodGroup||"—"}</span></td>
                    <td style={{ padding:"12px 14px" }}>{(p.history||[]).map(h=><span key={h} style={{ ...tag("#8b5cf6"),marginRight:4,marginBottom:3,display:"inline-block" }}>{h}</span>)}</td>
                    <td style={{ padding:"12px 14px" }}><button style={{ background:"#f1f5f9",border:`1px solid ${BR}`,borderRadius:7,padding:"4px 8px",cursor:"pointer",fontSize:11 }} onClick={()=>setPatProfile(p)}>View</button></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* appointments */}
        {appointments.length>0&&(
          <div>
            <h3 style={{ fontWeight:800, marginBottom:14 }}>All Appointments ({appointments.length})</h3>
            <div style={{ display:"grid", gridTemplateColumns: mob?"1fr":tab?"1fr 1fr":"repeat(3,1fr)", gap:14 }}>
              {appointments.map(a=>(
                <div key={a.id} style={{ ...card, padding:16, borderLeft:`4px solid ${a.doctorColor||R}` }}>
                  <div style={{ display:"flex", justifyContent:"space-between", marginBottom:8 }}>
                    <div style={{ fontWeight:800, fontSize:14 }}>{a.doctor}</div>
                    <span style={badge(true)}>{a.status}</span>
                  </div>
                  <div style={{ fontSize:13, color:SL, lineHeight:1.9 }}>
                    <div>👤 {a.patientName}</div><div>🩺 {a.specialty}</div><div>🕐 {a.slot} · {a.date}</div>
                    {a.reason&&<div>📝 {a.reason}</div>}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    );
  }

  /* ════════════════════════════════════
     MODALS
  ════════════════════════════════════ */
  function BookingModal(){
    if(!showBooking||!selDoc) return null;
    return(
      <div style={modal} onClick={e=>{ if(e.target===e.currentTarget&&!bookSuccess) setShowBooking(false); }}>
        <div style={mbox}>
          {bookSuccess?(
            <div style={{ textAlign:"center", padding:"24px 0" }}>
              <div style={{ fontSize:60, marginBottom:14 }}>✅</div>
              <h3 style={{ fontWeight:900, color:"#10b981", fontSize:20, marginBottom:8 }}>Appointment Confirmed!</h3>
              <p style={{ color:SL }}>Booked with <b>{selDoc.name}</b> at <b>{selSlot}</b></p>
            </div>
          ):(
            <>
              <div style={{ display:"flex", gap:14, alignItems:"center", marginBottom:22 }}>
                <div style={{ ...ava(selDoc.color,50), fontSize:17, borderRadius:12 }}>{selDoc.avatar}</div>
                <div>
                  <h3 style={{ fontWeight:800, fontSize:17, marginBottom:2 }}>Book Appointment</h3>
                  <div style={{ color:SL, fontSize:13 }}>{selDoc.name} · {selDoc.specialty} · {selDoc.consultFee}</div>
                </div>
              </div>
              <div style={{ display:"flex", flexDirection:"column", gap:15 }}>
                <div>
                  <label style={lbl}>Select Time Slot *</label>
                  <div style={{ display:"flex", flexWrap:"wrap", gap:8 }}>
                    {selDoc.slots.map(s=>(
                      <span key={s} style={{ ...slot, ...(selSlot===s?slotA:{}), fontFamily:"inherit" }} onClick={()=>setSelSlot(s)}>{s}</span>
                    ))}
                  </div>
                </div>
                {!loggedIn&&<div style={{ background:"#fffbeb",border:"1px solid #fbbf24",borderRadius:10,padding:"11px 14px",fontSize:13,color:"#92400e" }}>⚠️ <span style={{ color:R, fontWeight:700, cursor:"pointer" }} onClick={()=>{ setShowBooking(false);go("login"); }}>Login</span> to confirm booking.</div>}
                <div><label style={lbl}>Reason for Visit</label><input style={inp} placeholder="Brief description…" value={bookNote} onChange={e=>setBookNote(e.target.value)}/></div>
                <div style={{ display:"flex", gap:10 }}>
                  <button style={{ ...btnO, flex:1, borderColor:BR, color:SL }} onClick={()=>setShowBooking(false)}>Cancel</button>
                  <button style={{ ...btnP, flex:2 }} onClick={()=>loggedIn?doBook():go("login")} disabled={!selSlot}>{loggedIn?"Confirm Appointment":"Login to Book"}</button>
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    );
  }

  function DoctorProfileModal(){
    if(!docProfile) return null;
    const d=docProfile;
    return(
      <div style={modal} onClick={e=>{ if(e.target===e.currentTarget) setDocProfile(null); }}>
        <div style={mbox}>
          <div style={{ background:`linear-gradient(135deg,${d.color}20,${d.color}08)`, borderRadius:14, padding:mob?16:22, marginBottom:20, display:"flex", gap:16, alignItems:"flex-start" }}>
            <div style={{ ...ava(d.color,mob?60:74), fontSize:mob?22:26, borderRadius:18 }}>{d.avatar}</div>
            <div style={{ flex:1 }}>
              <h3 style={{ fontWeight:900, fontSize: mob?18:21, marginBottom:4 }}>{d.name}</h3>
              <span style={{ ...tag(d.color), display:"inline-block", marginBottom:8 }}>{d.specialty}</span>
              <div style={{ display:"flex", gap:8, flexWrap:"wrap" }}>
                <span style={badge(d.available)}>{d.available?"✅ Available":"❌ Unavailable"}</span>
                <span style={{ fontSize:13, fontWeight:700, color:R }}>{d.consultFee}/visit</span>
              </div>
            </div>
          </div>
          <p style={{ color:SL, fontSize:14, lineHeight:1.75, marginBottom:18 }}>{d.bio}</p>
          <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:10, marginBottom:18 }}>
            {[["⭐ Rating",d.rating],["🎓 Experience",d.experience],["👥 Patients",d.patients.toLocaleString()],["🏫 Education",d.education],["🌐 Languages",d.languages],["🏆 Awards",d.awards||"—"],["📞 Phone",d.phone||"—"],["📧 Email",d.email||"—"]].map(([l,v])=>(
              <div key={l} style={{ background:"#f8fafc", borderRadius:10, padding:12 }}>
                <div style={{ fontSize:10, color:"#94a3b8", fontWeight:700, marginBottom:3 }}>{l}</div>
                <div style={{ fontWeight:700, color:DP, fontSize:13, wordBreak:"break-word" }}>{v}</div>
              </div>
            ))}
          </div>
          {d.available&&d.slots.length>0&&(
            <div style={{ marginBottom:18 }}>
              <div style={{ fontSize:10, fontWeight:700, color:"#94a3b8", textTransform:"uppercase", letterSpacing:1, marginBottom:8 }}>Available Slots</div>
              <div style={{ display:"flex", flexWrap:"wrap", gap:7 }}>{d.slots.map(s=><span key={s} style={slot}>{s}</span>)}</div>
            </div>
          )}
          <div style={{ display:"flex", gap:10 }}>
            <button style={{ ...btnO, flex:1, borderColor:BR, color:SL }} onClick={()=>setDocProfile(null)}>Close</button>
            {d.available&&<button style={{ ...btnP, flex:2 }} onClick={()=>{ setDocProfile(null);setSelDoc(d);setShowBooking(true); }}>📅 Book Appointment</button>}
          </div>
        </div>
      </div>
    );
  }

  function PatientProfileModal(){
    if(!patProfile) return null;
    const p=patProfile;
    const pa=appointments.filter(a=>a.patientEmail===p.email);
    return(
      <div style={modal} onClick={e=>{ if(e.target===e.currentTarget) setPatProfile(null); }}>
        <div style={mbox}>
          <div style={{ display:"flex", gap:14, alignItems:"center", marginBottom:20 }}>
            <div style={{ ...ava(R,mob?52:64), fontSize:mob?20:24 }}>{p.name?.[0]}</div>
            <div>
              <h3 style={{ fontWeight:900, fontSize: mob?18:20, marginBottom:4 }}>{p.name}</h3>
              <div style={{ color:SL, fontSize:13 }}>Patient #{p.id} · Age {p.age}</div>
              <span style={badge(true)}>Active</span>
            </div>
          </div>
          <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:10, marginBottom:16 }}>
            {[["📧 Email",p.email],["📞 Phone",p.phone||"—"],["⚧ Gender",p.gender||"—"],["🎂 DOB",p.dob||"—"],["🩸 Blood",p.bloodGroup||"—"],["💊 Allergies",p.allergies||"None"],["🏠 Address",p.address||"—"],["📅 Appointments",pa.length]].map(([l,v])=>(
              <div key={l} style={{ background:"#f8fafc",borderRadius:10,padding:12 }}>
                <div style={{ fontSize:10,color:"#94a3b8",fontWeight:700,marginBottom:3 }}>{l}</div>
                <div style={{ fontWeight:700,color:DP,fontSize:13,wordBreak:"break-word" }}>{v}</div>
              </div>
            ))}
          </div>
          {(p.history||[]).length>0&&(
            <div style={{ marginBottom:16,padding:12,background:"#f8fafc",borderRadius:10 }}>
              <div style={{ fontSize:10,fontWeight:700,color:"#94a3b8",textTransform:"uppercase",letterSpacing:1,marginBottom:8 }}>Medical History</div>
              <div style={{ display:"flex",flexWrap:"wrap",gap:6 }}>{p.history.map(h=><span key={h} style={tag("#8b5cf6")}>{h}</span>)}</div>
            </div>
          )}
          {pa.length>0&&<div style={{ marginBottom:16 }}>
            <div style={{ fontSize:10,fontWeight:700,color:"#94a3b8",textTransform:"uppercase",letterSpacing:1,marginBottom:8 }}>Appointments</div>
            {pa.map(a=><div key={a.id} style={{ background:"#fff",borderRadius:9,padding:10,border:`1px solid ${BR}`,marginBottom:6,fontSize:13 }}><b>{a.doctor}</b> · {a.slot} · {a.date}</div>)}
          </div>}
          <button style={{ ...btnP, width:"100%" }} onClick={()=>setPatProfile(null)}>Close</button>
        </div>
      </div>
    );
  }

  function AddDoctorModal(){
    if(!showAddDoc) return null;
    return(
      <div style={modal} onClick={e=>{ if(e.target===e.currentTarget) setShowAddDoc(false); }}>
        <div style={mbox}>
          <h3 style={{ fontWeight:800,fontSize:19,marginBottom:6 }}>Add New Doctor</h3>
          <p style={{ color:SL,fontSize:13,marginBottom:20 }}>Fill in the details to add a doctor to the team</p>
          <div style={{ display:"flex",flexDirection:"column",gap:13 }}>
            {[["name","Doctor Name *","Dr. Jane Smith"],["specialty","Specialty *","Cardiologist"],["experience","Experience","10 years"],["education","Education","Harvard Medical School"],["phone","Phone","555-1000"],["email","Email","dr.jane@hospital.com"],["consultFee","Consultation Fee","$120"],["languages","Languages","English, Spanish"],["awards","Awards","Best Doctor 2024"],["bio","Short Bio","Experienced specialist…"],["slots","Time Slots (comma-sep)","09:00 AM, 02:00 PM"]].map(([k,l,ph])=>(
              <div key={k}><label style={lbl}>{l}</label><input style={inp} placeholder={ph} value={nd[k]} onChange={e=>setNd({...nd,[k]:e.target.value})}/></div>
            ))}
            <div style={{ display:"flex",gap:10,marginTop:6 }}>
              <button style={{ ...btnO,flex:1,borderColor:BR,color:SL }} onClick={()=>setShowAddDoc(false)}>Cancel</button>
              <button style={{ ...btnP,flex:2 }} onClick={doAddDoc}>Add Doctor</button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  function EditDoctorModal(){
    if(!editDocModal||!editDoc) return null;
    return(
      <div style={modal} onClick={e=>{ if(e.target===e.currentTarget){ setEditDocModal(false);setEditDoc(null); } }}>
        <div style={mbox}>
          <h3 style={{ fontWeight:800,fontSize:19,marginBottom:6 }}>Edit Doctor Profile</h3>
          <p style={{ color:SL,fontSize:13,marginBottom:20 }}>Update details for {editDoc.name}</p>
          <div style={{ display:"flex",flexDirection:"column",gap:13 }}>
            {[["name","Name"],["specialty","Specialty"],["experience","Experience"],["education","Education"],["phone","Phone"],["email","Email"],["consultFee","Fee"],["languages","Languages"],["awards","Awards"],["bio","Bio"],["slots","Slots (comma-sep)"]].map(([k,l])=>(
              <div key={k}><label style={lbl}>{l}</label><input style={inp} value={editDoc[k]||""} onChange={e=>setEditDoc({...editDoc,[k]:e.target.value})}/></div>
            ))}
            <div><label style={lbl}>Available</label>
              <select style={inp} value={editDoc.available?"yes":"no"} onChange={e=>setEditDoc({...editDoc,available:e.target.value==="yes"})}>
                <option value="yes">Yes</option><option value="no">No</option>
              </select>
            </div>
            <div style={{ display:"flex",gap:10,marginTop:6 }}>
              <button style={{ ...btnO,flex:1,borderColor:BR,color:SL }} onClick={()=>{ setEditDocModal(false);setEditDoc(null); }}>Cancel</button>
              <button style={{ ...btnP,flex:2 }} onClick={doEditDoc}>Save Changes</button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  /* ════════════════════════════════════
     RENDER
  ════════════════════════════════════ */
  return(
    <div style={{ fontFamily:"'Georgia',serif", background:"#f8f9fc", minHeight:"100vh", color:DP }}>
      <Nav/>
      {page==="home"       && <HomePage/>}
      {page==="doctors"    && <DoctorsPage/>}
      {page==="appointments"&& <AppointmentsPage/>}
      {page==="login"      && <LoginPage/>}
      {page==="patientDash"&& loggedIn&&currentUser?.type==="patient" && <PatientDashboard/>}
      {page==="adminDash"  && loggedIn&&currentUser?.type==="admin"   && <AdminDashboard/>}

      <BookingModal/>
      <DoctorProfileModal/>
      <PatientProfileModal/>
      <AddDoctorModal/>
      <EditDoctorModal/>

      {/* mobile bottom tab bar */}
      {mob&&(
        <div style={{ position:"fixed", bottom:0, left:0, right:0, background:DK, borderTop:"1px solid rgba(255,255,255,0.1)", display:"flex", zIndex:150, paddingBottom:"env(safe-area-inset-bottom,0px)" }}>
          {[["home","🏠","Home"],["doctors","👨‍⚕️","Doctors"],["appointments","📅","Book"],loggedIn&&currentUser?.type==="patient"?["patientDash","👤","Portal"]:["login","🔑","Login"]].map(item=>{
            if(!item) return null;
            const [p,icon,l]=item;
            return(
              <button key={p} onClick={()=>go(p)} style={{ flex:1, background:"transparent", border:"none", color:page===p?R:"#94a3b8", padding:"10px 4px 8px", cursor:"pointer", fontSize:10, fontWeight:700, display:"flex", flexDirection:"column", alignItems:"center", gap:2, fontFamily:"inherit" }}>
                <span style={{ fontSize:20 }}>{icon}</span>{l}
              </button>
            );
          })}
        </div>
      )}

      <footer style={{ background:`linear-gradient(135deg,${NV},${DK})`, color:"#94a3b8", textAlign:"center", padding: mob?"24px 16px 80px":"28px 32px", fontSize:13 }}>
        <div style={{ fontWeight:800, color:"#e2e8f0", marginBottom:6 }}>MediCare<span style={{color:R}}>+</span> Advanced Healthcare</div>
        <div>© 2026 MediCare Hospital · Emergency: <b style={{color:R}}>911</b> · Helpline: 1-800-MEDICARE</div>
      </footer>
    </div>
  );
}
