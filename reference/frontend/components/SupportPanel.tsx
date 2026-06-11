"use client";

import { useState, useRef, useEffect } from "react";
import styles from "./SupportPanel.module.css";
import { setResidentLanguageManual } from "@/lib/hearth-translation-service";

function GlobeIcon() {
  return (
    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#7a9cbd" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
      <circle cx="12" cy="12" r="10" />
      <ellipse cx="12" cy="12" rx="4" ry="10" />
      <line x1="2" y1="12" x2="22" y2="12" />
    </svg>
  );
}

const languages = [
  { name: "Arabic",           flag: "🇸🇦", code: "ar"  },
  { name: "Dutch",            flag: "🇳🇱", code: "nl"  },
  { name: "English",          flag: "🇬🇧", code: "en"  },
  { name: "French",           flag: "🇫🇷", code: "fr"  },
  { name: "German",           flag: "🇩🇪", code: "de"  },
  { name: "Greek",            flag: "🇬🇷", code: "el"  },
  { name: "Hindi",            flag: "🇮🇳", code: "hi"  },
  { name: "Indonesian",       flag: "🇮🇩", code: "id"  },
  { name: "Italian",          flag: "🇮🇹", code: "it"  },
  { name: "Japanese",         flag: "🇯🇵", code: "ja"  },
  { name: "Korean",           flag: "🇰🇷", code: "ko"  },
  { name: "Malay",            flag: "🇲🇾", code: "ms"  },
  { name: "Mandarin Chinese", flag: "🇨🇳", code: "zh"  },
  { name: "Polish",           flag: "🇵🇱", code: "pl"  },
  { name: "Portuguese",       flag: "🇵🇹", code: "pt"  },
  { name: "Punjabi",          flag: "🇮🇳", code: "pa"  },
  { name: "Russian",          flag: "🇷🇺", code: "ru"  },
  { name: "Spanish",          flag: "🇪🇸", code: "es"  },
  { name: "Thai",             flag: "🇹🇭", code: "th"  },
  { name: "Turkish",          flag: "🇹🇷", code: "tr"  },
  { name: "Ukrainian",        flag: "🇺🇦", code: "uk"  },
  { name: "Vietnamese",       flag: "🇻🇳", code: "vi"  },
];

function ChatIcon() {
  return <svg viewBox="0 0 24 24" fill="currentColor" width="20" height="20" aria-hidden><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z" /></svg>;
}
function HomeIcon() {
  return <svg viewBox="0 0 24 24" fill="currentColor" width="20" height="20" aria-hidden><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z" /></svg>;
}
function ShieldIcon() {
  return <svg viewBox="0 0 24 24" fill="currentColor" width="20" height="20" aria-hidden><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4z" /></svg>;
}
function HeartIcon() {
  return <svg viewBox="0 0 24 24" fill="currentColor" width="20" height="20" aria-hidden><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" /></svg>;
}
function FamilyIcon() {
  return <svg viewBox="0 0 24 24" fill="currentColor" width="20" height="20" aria-hidden><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z" /></svg>;
}
function HealthIcon() {
  return <svg viewBox="0 0 24 24" fill="currentColor" width="20" height="20" aria-hidden><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-2 10h-4v4h-2v-4H7v-2h4V7h2v4h4v2z" /></svg>;
}
function ResourcesIcon() {
  return <svg viewBox="0 0 24 24" fill="currentColor" width="20" height="20" aria-hidden><path d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z" /></svg>;
}
function ComfortIcon() {
  return <svg viewBox="0 0 24 24" fill="currentColor" width="20" height="20" aria-hidden><path d="M20 3H4v10c0 2.21 1.79 4 4 4h6c2.21 0 4-1.79 4-4v-3h2c1.11 0 2-.89 2-2V5c0-1.11-.89-2-2-2zm0 5h-2V5h2v3zM4 19h16v2H4z" /></svg>;
}

const categories = [
  {
    title: "Conversation Starters",
    Icon: ChatIcon,
    items: [
      "Hi, I am really glad you are here. How are you feeling right now?",
      "What would you like to talk about today?",
      "Is there something on your mind you would like to share?",
      "What has been going on for you lately?",
      "Where would you like to start?",
      "Would you like to share what brought you in today?",
      "What has today been like for you so far?",
      "Is there anything you have been wanting to talk about?",
      "Would it help to start with what feels hardest right now?",
      "How can I best support you right now?",
      "Is there a particular concern you would like to focus on today?",
      "What is one thing that would make today a little easier for you?",
    ],
  },
  {
    title: "Comfort",
    Icon: ComfortIcon,
    items: [
      "Take all the time you need. There is no rush.",
      "You are safe here. We will go through this together.",
      "I am here to listen. You can share as much or as little as you want.",
      "We can go at whatever pace feels right for you.",
      "You do not have to go through this alone. I am here with you.",
      "It is okay to take a moment if you need to.",
      "You do not need to have everything figured out right now.",
      "Whatever you are feeling is okay.",
      "I am here with you, and we can figure this out together.",
      "What would feel most helpful for you right now?",
      "You are doing the best you can, and that is enough.",
      "We are here for you, no matter what.",
    ],
  },
  {
    title: "Needs",
    Icon: HomeIcon,
    items: [
      "Would you like something to eat or drink?",
      "Do you need a place to stay tonight? I can help check what is available.",
      "Would you like access to a shower or clean clothing?",
      "Do you need any hygiene items like soap, a toothbrush, or menstrual products?",
      "Is there anything you need right now that we can help with?",
      "Would a blanket or something warm help you feel more comfortable?",
      "Would you like a quieter or more private space to rest?",
      "Do you need help keeping your belongings or documents safe?",
      "Would you like to charge your phone or use a phone to call someone?",
      "What would help you feel more comfortable or supported right now?",
      "Do you need any transportation or help getting somewhere?",
      "Is there anything else we can do to meet your needs right now?",
    ],
  },
  {
    title: "Safety",
    Icon: ShieldIcon,
    items: [
      "Are you in immediate danger right now?",
      "Do you feel safe being here with us?",
      "Is there someone you are worried about or afraid of?",
      "Would you like to speak somewhere more private?",
      "Does anyone know where you are right now?",
      "We will not share your information or location without your permission.",
      "Would you like us to contact someone you trust?",
      "Do you feel comfortable staying here tonight?",
      "Is there anything we can do to help you feel safer?",
      "Do you need us to take any immediate steps to support your safety?",
      "Would you like us to stay nearby while you settle in?",
      "Are there any people or places you are trying to avoid right now?",
    ],
  },
  {
    title: "Wellbeing",
    Icon: HeartIcon,
    items: [
      "How are you feeling right now?",
      "You have been through a lot. It is okay to feel overwhelmed.",
      "Would you like some quiet time to yourself?",
      "Is there anything weighing on your mind right now?",
      "It took courage to come here.",
      "Would you like to speak with a counselor or support worker?",
      "Do you have support from anyone nearby?",
      "Have you been able to rest and eat okay?",
      "Would it help to talk about what has been happening?",
      "What would help you feel a little better right now?",
      "Is there something specific that has been on your mind?",
      "You are not a burden. We are here because we care.",
    ],
  },
  {
    title: "Family",
    Icon: FamilyIcon,
    items: [
      "Do you have children or family members with you?",
      "Are your children safe and nearby?",
      "What do your children need right now?",
      "We have support and resources for families. Would you like to hear more?",
      "Would you like a space or activities for your children?",
      "Do your children need food, clothing, or care items?",
      "Are you worried about any family members who are not with you?",
      "Would you like help contacting a family member?",
      "Do any of your children have needs we should know about?",
      "How can we best support you and your family right now?",
      "Would you like support connecting with family services in the area?",
      "Are there any custody or legal concerns we should be aware of?",
    ],
  },
  {
    title: "Health",
    Icon: HealthIcon,
    items: [
      "Are you feeling physically okay right now?",
      "Are you in any pain or discomfort?",
      "Do you need access to medication right now?",
      "Would you like to see a doctor or nurse?",
      "Do you have any health needs we should be aware of?",
      "Do you have any allergies we should know about?",
      "Are you feeling dizzy, faint, or unwell?",
      "Have you had something to eat or drink recently?",
      "Would you like first aid or medical attention?",
      "We can help connect you with a health clinic. Would that be helpful?",
      "Do you have any mental health needs we can support you with?",
      "Would you like help getting a prescription filled or accessing a pharmacy?",
    ],
  },
  {
    title: "Resources",
    Icon: ResourcesIcon,
    items: [
      "We can help you find a safe place to stay. Would you like that?",
      "There are legal services available. Would you like more information?",
      "We can connect you with a case worker who can help guide your next steps.",
      "Counseling and mental health services are available. Would you like a referral?",
      "Would you like help applying for emergency financial support?",
      "Do you need help with transportation to get somewhere safe?",
      "Would you like information about your rights and options?",
      "We can help connect you with local support organizations.",
      "Are you looking for longer term housing support?",
      "What kind of support would be most helpful for you right now?",
      "Would you like help with identification or important documents?",
      "We can help you understand what services you are eligible for.",
    ],
  },
];

type Category = (typeof categories)[0];

interface SupportPanelProps {
  onSelect: (text: string) => void;
}

export function SupportPanel({ onSelect }: SupportPanelProps) {
  const [selected, setSelected] = useState<Category | null>(null);
  const [language, setLanguage] = useState("");
  const [langError, setLangError] = useState(false);
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const selectedLang = languages.find((l) => l.name === language) ?? null;

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setDropdownOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  function handleLanguageSelect(lang: typeof languages[0]) {
    setLanguage(lang.name);
    setLangError(false);
    setDropdownOpen(false);
    setResidentLanguageManual(lang.name, lang.code, lang.flag);
  }

  function handlePromptClick(item: string) {
    if (!language) {
      setLangError(true);
      return;
    }
    onSelect(item);
  }

  return (
    <div className={styles.panel}>
      {selected && (
        <button className={styles.back} onClick={() => setSelected(null)}>← Back</button>
      )}

      <div
        ref={dropdownRef}
        className={`${styles.langDropdown} ${langError ? styles.langSelectError : ""}`}
      >
        <button
          className={styles.langTrigger}
          onClick={() => setDropdownOpen((o) => !o)}
          aria-haspopup="listbox"
          aria-expanded={dropdownOpen}
        >
          {!selectedLang && <GlobeIcon />}
          <span>{selectedLang ? <>{selectedLang.flag}&nbsp;&nbsp;{selectedLang.name}</> : "Language"}</span>
        </button>

        {dropdownOpen && (
          <ul className={styles.langList} role="listbox">
            {languages.map((l) => (
              <li
                key={l.name}
                role="option"
                aria-selected={l.name === language}
                className={`${styles.langOption} ${l.name === language ? styles.langOptionActive : ""}`}
                onClick={() => handleLanguageSelect(l)}
              >
                {l.flag}&nbsp;&nbsp;{l.name}
              </li>
            ))}
          </ul>
        )}
      </div>

      {langError && (
        <p className={styles.langErrorMsg}>Please select a language first</p>
      )}

      {selected ? (
        <>
          <h2 className={styles.categoryTitle}>{selected.title}</h2>
          <div className={styles.grid}>
            {selected.items.map((item, i) => (
              <button key={i} className={styles.promptCard} onClick={() => handlePromptClick(item)}>
                {item}
              </button>
            ))}
          </div>
        </>
      ) : (
        <div className={styles.categoryList}>
          {categories.map((cat) => (
            <button key={cat.title} className={styles.categoryBtn} onClick={() => setSelected(cat)}>
              <cat.Icon />
              <span>{cat.title}</span>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
