import { StyleSheet, Switch, Image, Dimensions} from 'react-native';
import { Text, View } from '../components/Themed';
import { RootTabScreenProps } from '../types';
import { FontAwesome5 } from '@expo/vector-icons';
import React, { useState, useEffect, useContext } from 'react';
import { Pressable, Hoverable, } from "react-native-web-hover";
import { useRouter } from 'next/router'
import { TwitterContext } from '../context/TwitterContext'
import { RiHome7Line, RiHome7Fill, RiFileList2Fill, RiWomenLine } from 'react-icons/ri'
import { BiHash } from 'react-icons/bi'
import { FiBell, FiMoreHorizontal } from 'react-icons/fi'
import { HiOutlineMail, HiMail } from 'react-icons/hi'
import { FaRegListAlt, FaHashtag, FaBell } from 'react-icons/fa'
import { CgMoreO, CgRowLast } from 'react-icons/cg'
import { VscTwitter } from 'react-icons/vsc';
import Modal from 'react-modal';
import { customStyles } from '../lib/constants';
import tw3ttorlogo from '../assets/images/tw3tterlogo.png';
// import ProfileImageMinter from './profile/mintingModal/ProfileImageMinter'
import {
  BsBookmark,
  BsBookmarkFill,
  BsPerson,
  BsPersonFill,
} from 'react-icons/bs'
import SidebarOption from '../components/SidebarOptions';


export default function TabOneScreen({ navigation }: RootTabScreenProps<'TabOne'>) {

  const window = Dimensions.get("window");
  const screen = Dimensions.get("screen");
  const [dimensions, setDimensions] = useState({ window, screen });
  const [isPressed, setPressed] = useState(false);
  useEffect(() => {
    const subscription: any = Dimensions.addEventListener(
      "change",
      ({ window, screen }) => {
        setDimensions({ window, screen });
      }
    );
    return () => subscription?.remove();
  });
  const toggleSwitch = () => setPressed(previousState => !previousState);

  return (
    <View style={styles.container}>
      {/* <Switch
      ios_backgroundColor="#3e3e3e"
      onValueChange={toggleSwitch}
      value={isPressed}
      /> */}
    
      {/* <View style={styles.dimensionsContainer}>
        <Text style={styles.dimensionsHeader}>Window Dimensions</Text>
        {Object.entries(dimensions.window).map(([key, value]) => (
          <Text>{key} - {value}</Text>
        ))}
        <Text style={styles.dimensionsHeader}>Screen Dimensions</Text>
        {Object.entries(dimensions.screen).map(([key, value]) => (
          <Text>{key} - {value}</Text>
        ))}
      </View> */}
      <View>
        <Image source={tw3ttorlogo.png} style={{ width: 200, height: 200 }}/>
      </View>
      <View style={[styles.tw3tterIconContainer]}>
        <Pressable
          style={({ pressed }) => [
            {
              backgroundColor: pressed
                ? '#2f4f4f'
                : '#15202b'
            },
            styles.wrapperCustom
          ]}>
          {({ pressed }) => (
            <FontAwesome5 name="dragon" size={24} color="green" />
          )}
        </Pressable>
      </View>
      <View style={[styles.tw3tterIconContainer]}>
        <Text style={[styles.buttonText]}>
          <FontAwesome5 name="home" size={24} color="white" style={{ marginRight: 10 }} />
          Home
        </Text>
      </View>
      <View style={[styles.tw3tterIconContainer]}>
        <Text>
          <FontAwesome5 name="home" size={24} color="white" style={{ marginRight: 10 }}/>
          Explore
        </Text>
      </View>
      <View style={[styles.tw3tterIconContainer]}>
        <Text>
        <FontAwesome5 name="home" size={24} color="white" style={{ marginRight: 10 }} />
          Notifications
        </Text>
      </View>

    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    // flexDirection: 'row',
    padding: 4,
    // backgroundColor: '#15202b',
    // alignItems: 'center',
    // justifyContent: 'center',
    // justifyContent: 'space-between',
  }, 
  wrapper: {

  },
  wrapperCustom: {
    borderRadius: 8,
    padding: 6
  },
  tw3tterIconContainer: {
    backgroundColor: '#15202b',
    padding: 10,
    fontSize: 30,
    fontWeight: 'bold',
    margin: 4, 
    borderWidth: 2,
    borderRadius: 6,

  },

  navContainer: {
  },

  tw33tButton: {
   
  },
  buttonText: {
    marginRight: 10
     
  },
  separator: {
    marginVertical: 30,
    height: 1,
    width: '80%',
  },
  dimensionsContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center"
  },
  dimensionsHeader: {
    fontSize: 16,
    marginVertical: 10
  }
  // const style = {
  //   wrapper: `flex-[0.7] px-8 flex flex-col`,
  //   tw3tterIconContainer: `text-3xl m-4`,
  //   tw33tButton: `bg-[#1d9bf0] hover:bg-[#1b8cd8] flex items-center justify-center font-bold rounded-3xl h-[50px] mt-[20px] cursor-pointer`,
  //   navContainer: `flex-1`,
  //   profileButton: `flex items-center mb-6 cursor-pointer hover:bg-[#333c45] rounded-[100px] p-2`,
  //   profileLeft: `flex item-center justify-center mr-4`,
  //   profileImage: `height-12 w-12 rounded-full`,
  //   profileRight: `flex-1 flex`,
  //   details: `flex-1`,
  //   name: `text-lg`,
  //   handle: `text-[#8899a6]`,
  //   moreContainer: `flex items-center mr-2`,
  // }

});
